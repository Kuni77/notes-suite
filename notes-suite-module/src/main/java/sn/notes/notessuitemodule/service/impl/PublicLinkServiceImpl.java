package sn.notes.notessuitemodule.service.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import sn.notes.notessuitemodule.domain.Note;
import sn.notes.notessuitemodule.domain.PublicLink;
import sn.notes.notessuitemodule.domain.User;
import sn.notes.notessuitemodule.domain.enums.Visibility;
import sn.notes.notessuitemodule.exception.ResourceNotFoundException;
import sn.notes.notessuitemodule.exception.UnauthorizedException;
import sn.notes.notessuitemodule.repository.NoteRepository;
import sn.notes.notessuitemodule.repository.PublicLinkRepository;
import sn.notes.notessuitemodule.service.dto.NoteResponse;
import sn.notes.notessuitemodule.service.dto.PublicLinkResponse;
import sn.notes.notessuitemodule.service.interfaces.PublicLinkService;
import sn.notes.notessuitemodule.service.interfaces.UserService;
import sn.notes.notessuitemodule.service.mapper.NoteMapper;
import sn.notes.notessuitemodule.service.mapper.PublicLinkMapper;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class PublicLinkServiceImpl implements PublicLinkService {
    private final PublicLinkRepository publicLinkRepository;
    private final NoteRepository noteRepository;
    private final UserService userService;
    private final PublicLinkMapper publicLinkMapper;
    private final NoteMapper noteMapper;

    @Override
    @Transactional
    public PublicLinkResponse createPublicLink(Long noteId, String userEmail) {
        log.info("Creating public link for note: {}", noteId);

        Note note = findNoteById(noteId);
        User user = userService.findByEmail(userEmail);

        validateNoteOwnership(note, user);

        // Mettre à jour la visibilité de la note
        note.setVisibility(Visibility.PUBLIC);
        noteRepository.save(note);

        String urlToken = UUID.randomUUID().toString();

        PublicLink publicLink = PublicLink.builder()
                .note(note)
                .urlToken(urlToken)
                .build();

        publicLink = publicLinkRepository.save(publicLink);

        log.info("Public link created: {}", urlToken);
        return publicLinkMapper.toResponse(publicLink);
    }

    @Override
    @Transactional(readOnly = true)
    public List<PublicLinkResponse> getPublicLinksForNote(Long noteId, String userEmail) {
        log.info("Getting public links for note: {}", noteId);

        Note note = findNoteById(noteId);
        User user = userService.findByEmail(userEmail);

        validateNoteOwnership(note, user);

        List<PublicLink> publicLinks = publicLinkRepository.findByNote(note);
        return publicLinkMapper.toResponseList(publicLinks);
    }

    @Override
    @Transactional(readOnly = true)
    public NoteResponse getNoteByPublicToken(String urlToken) {
        log.info("Getting note by public token: {}", urlToken);

        PublicLink publicLink = publicLinkRepository.findByUrlToken(urlToken)
                .orElseThrow(() -> new ResourceNotFoundException("Public link not found"));

        // Vérifier l'expiration si définie
        if (publicLink.getExpiresAt() != null && publicLink.getExpiresAt().isBefore(LocalDateTime.now())) {
            throw new UnauthorizedException("This public link has expired");
        }

        Note note = publicLink.getNote();

        if (note.getVisibility() != Visibility.PUBLIC) {
            throw new UnauthorizedException("This note is no longer public");
        }

        return noteMapper.toResponse(note);
    }

    @Override
    @Transactional
    public void deletePublicLink(Long publicLinkId, String userEmail) {
        log.info("Deleting public link with ID: {}", publicLinkId);

        PublicLink publicLink = publicLinkRepository.findById(publicLinkId)
                .orElseThrow(() -> new ResourceNotFoundException("Public link not found with id: " + publicLinkId));

        User user = userService.findByEmail(userEmail);

        validateNoteOwnership(publicLink.getNote(), user);

        publicLinkRepository.delete(publicLink);

        // Si c'était le dernier lien public, remettre la note en SHARED ou PRIVATE
        Note note = publicLink.getNote();
        if (publicLinkRepository.findByNote(note).isEmpty()) {
            if (note.getShares().isEmpty()) {
                note.setVisibility(Visibility.PRIVATE);
            } else {
                note.setVisibility(Visibility.SHARED);
            }
            noteRepository.save(note);
        }

        log.info("Public link deleted successfully: {}", publicLinkId);
    }

    // Méthodes utilitaires privées

    private Note findNoteById(Long id) {
        return noteRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Note not found with id: " + id));
    }

    private void validateNoteOwnership(Note note, User user) {
        if (!note.getOwner().getId().equals(user.getId())) {
            throw new UnauthorizedException("You don't have permission to manage public links for this note");
        }
    }
}
