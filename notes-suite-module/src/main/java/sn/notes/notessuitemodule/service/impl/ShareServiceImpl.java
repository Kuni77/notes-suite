package sn.notes.notessuitemodule.service.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import sn.notes.notessuitemodule.domain.*;
import sn.notes.notessuitemodule.domain.enums.Permission;
import sn.notes.notessuitemodule.domain.enums.Visibility;
import sn.notes.notessuitemodule.exception.BadRequestException;
import sn.notes.notessuitemodule.exception.ResourceNotFoundException;
import sn.notes.notessuitemodule.exception.UnauthorizedException;
import sn.notes.notessuitemodule.repository.NoteRepository;
import sn.notes.notessuitemodule.repository.ShareRepository;
import sn.notes.notessuitemodule.service.dto.ShareResponse;
import sn.notes.notessuitemodule.service.dto.ShareWithUserRequest;
import sn.notes.notessuitemodule.service.interfaces.ShareService;
import sn.notes.notessuitemodule.service.interfaces.UserService;
import sn.notes.notessuitemodule.service.mapper.ShareMapper;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class ShareServiceImpl implements ShareService {
    private final ShareRepository shareRepository;
    private final NoteRepository noteRepository;
    private final UserService userService;
    private final ShareMapper shareMapper;

    @Override
    @Transactional
    public ShareResponse shareNoteWithUser(Long noteId, ShareWithUserRequest request, String ownerEmail) {
        log.info("Sharing note {} with user: {}", noteId, request.email());

        Note note = findNoteById(noteId);
        User owner = userService.findByEmail(ownerEmail);

        validateNoteOwnership(note, owner);

        User sharedWithUser = userService.findByEmail(request.email());

        if (owner.getId().equals(sharedWithUser.getId())) {
            throw new BadRequestException("Cannot share note with yourself");
        }

        if (shareRepository.existsByNoteAndSharedWithUser(note, sharedWithUser)) {
            throw new BadRequestException("Note already shared with this user");
        }

        // Mettre à jour la visibilité de la note
        if (note.getVisibility() == Visibility.PRIVATE) {
            note.setVisibility(Visibility.SHARED);
            noteRepository.save(note);
        }

        Share share = Share.builder()
                .note(note)
                .sharedWithUser(sharedWithUser)
                .permission(Permission.READ)
                .build();

        share = shareRepository.save(share);

        log.info("Note shared successfully with user: {}", request.email());
        return shareMapper.toResponse(share);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ShareResponse> getSharesForNote(Long noteId, String userEmail) {
        log.info("Getting shares for note: {}", noteId);

        Note note = findNoteById(noteId);
        User user = userService.findByEmail(userEmail);

        validateNoteOwnership(note, user);

        List<Share> shares = shareRepository.findByNote(note);
        return shareMapper.toResponseList(shares);
    }

    @Override
    @Transactional
    public void removeShare(Long shareId, String userEmail) {
        log.info("Removing share with ID: {}", shareId);

        Share share = shareRepository.findById(shareId)
                .orElseThrow(() -> new ResourceNotFoundException("Share not found with id: " + shareId));

        User user = userService.findByEmail(userEmail);

        validateNoteOwnership(share.getNote(), user);

        shareRepository.delete(share);

        // Si c'était le dernier partage, remettre la note en privé
        Note note = share.getNote();
        if (shareRepository.findByNote(note).isEmpty() && note.getPublicLinks().isEmpty()) {
            note.setVisibility(Visibility.PRIVATE);
            noteRepository.save(note);
        }

        log.info("Share removed successfully: {}", shareId);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean hasAccessToNote(Long noteId, String userEmail) {
        Note note = findNoteById(noteId);
        User user = userService.findByEmail(userEmail);

        // Propriétaire
        if (note.getOwner().getId().equals(user.getId())) {
            return true;
        }

        // Partagé avec l'utilisateur
        return shareRepository.existsByNoteAndSharedWithUser(note, user);
    }

    // Méthodes utilitaires privées

    private Note findNoteById(Long id) {
        return noteRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Note not found with id: " + id));
    }

    private void validateNoteOwnership(Note note, User user) {
        if (!note.getOwner().getId().equals(user.getId())) {
            throw new UnauthorizedException("You don't have permission to manage shares for this note");
        }
    }
}
