package sn.notes.notessuitemodule.service.impl;

import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.JoinType;
import jakarta.persistence.criteria.Predicate;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import sn.notes.notessuitemodule.domain.*;
import sn.notes.notessuitemodule.domain.enums.Visibility;
import sn.notes.notessuitemodule.exception.ResourceNotFoundException;
import sn.notes.notessuitemodule.exception.UnauthorizedException;
import sn.notes.notessuitemodule.repository.NoteRepository;
import sn.notes.notessuitemodule.repository.NoteTagRepository;
import sn.notes.notessuitemodule.repository.ShareRepository;
import sn.notes.notessuitemodule.repository.TagRepository;
import sn.notes.notessuitemodule.service.criteria.NoteSearchCriteria;
import sn.notes.notessuitemodule.service.dto.CreateNoteRequest;
import sn.notes.notessuitemodule.service.dto.NoteResponse;
import sn.notes.notessuitemodule.service.dto.UpdateNoteRequest;
import sn.notes.notessuitemodule.service.interfaces.NoteService;
import sn.notes.notessuitemodule.service.interfaces.UserService;
import sn.notes.notessuitemodule.service.mapper.NoteMapper;
import sn.notes.notessuitemodule.service.specification.NoteSpecifications;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class NoteServiceImpl implements NoteService {
    private final NoteRepository noteRepository;
    private final UserService userService;
    private final TagRepository tagRepository;
    private final NoteTagRepository noteTagRepository;
    private final ShareRepository shareRepository;
    private final NoteMapper noteMapper;

    @Override
    @Transactional
    public NoteResponse createNote(CreateNoteRequest request, String userEmail) {
        log.info("Creating note for user: {}", userEmail);

        User owner = userService.findByEmail(userEmail);

        Note note = Note.builder()
                .title(request.title())
                .contentMd(request.contentMd())
                .visibility(Visibility.PRIVATE)
                .owner(owner)
                .build();

        note = noteRepository.save(note);

        // Gérer les tags
        if (request.tags() != null && !request.tags().isEmpty()) {
            attachTagsToNote(note, request.tags());
        }

        log.info("Note created with ID: {}", note.getId());
        return noteMapper.toResponse(note);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<NoteResponse> searchNotes(NoteSearchCriteria criteria, String userEmail) {
        log.info("Searching notes for user: {} with criteria: {}", userEmail, criteria);

        User owner = userService.findByEmail(userEmail);

        Specification<Note> spec = NoteSpecifications.searchWithFilters(
                owner,
                criteria.getQuery(),
                criteria.getVisibility(),
                criteria.getTag()
        );

        Sort sort = Sort.by(
                criteria.getSortOrder().equalsIgnoreCase("asc")
                        ? Sort.Direction.ASC
                        : Sort.Direction.DESC,
                criteria.getSortField()
        );

        Pageable pageable = PageRequest.of(
                criteria.getPageNumber(),
                criteria.getPageSize(),
                sort
        );

        Page<Note> notesPage = noteRepository.findAll(spec, pageable);

        return notesPage.map(noteMapper::toResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public NoteResponse getNoteById(Long id, String userEmail) {
        log.info("Getting note with ID: {} for user: {}", id, userEmail);

        Note note = findNoteById(id);
        User user = userService.findByEmail(userEmail);

        validateNoteAccess(note, user);

        return noteMapper.toResponse(note);
    }

    @Override
    @Transactional
    public NoteResponse updateNote(Long id, UpdateNoteRequest request, String userEmail) {
        log.info("Updating note with ID: {} for user: {}", id, userEmail);

        Note note = findNoteById(id);
        User user = userService.findByEmail(userEmail);

        validateNoteOwnership(note, user);

        if (request.title() != null) {
            note.setTitle(request.title());
        }

        if (request.contentMd() != null) {
            note.setContentMd(request.contentMd());
        }

        if (request.visibility() != null) {
            note.setVisibility(request.visibility());
        }

        if (request.tags() != null) {
            // Supprimer les anciens tags
            noteTagRepository.deleteByNote(note);
            // Ajouter les nouveaux tags
            attachTagsToNote(note, request.tags());
        }

        note = noteRepository.save(note);

        log.info("Note updated successfully: {}", id);
        return noteMapper.toResponse(note);
    }

    @Override
    @Transactional
    public void deleteNote(Long id, String userEmail) {
        log.info("Deleting note with ID: {} for user: {}", id, userEmail);

        Note note = findNoteById(id);
        User user = userService.findByEmail(userEmail);

        validateNoteOwnership(note, user);

        noteRepository.delete(note);

        log.info("Note deleted successfully: {}", id);
    }

    @Transactional(readOnly = true)
    public Page<NoteResponse> getSharedNotes(NoteSearchCriteria criteria, String userEmail) {
        log.info("Getting notes shared with user: {} with criteria: {}", userEmail, criteria);

        User user = userService.findByEmail(userEmail);

        // Récupérer les shares de l'utilisateur
        List<Share> shares = shareRepository.findBySharedWithUser(user);
        List<Long> sharedNoteIds = shares.stream()
                .map(share -> share.getNote().getId())
                .collect(Collectors.toList());

        if (sharedNoteIds.isEmpty()) {
            return Page.empty();
        }

        // Créer une specification pour les notes partagées avec filtres
        Specification<Note> spec = (root, query, criteriaBuilder) -> {
            List<Predicate> predicates = new ArrayList<>();

            // 1. Filter by shared note IDs
            predicates.add(root.get("id").in(sharedNoteIds));

            // 2. Filter by query (search in title)
            if (criteria.getQuery() != null && !criteria.getQuery().isBlank()) {
                String searchPattern = "%" + criteria.getQuery().toLowerCase() + "%";
                predicates.add(criteriaBuilder.like(
                        criteriaBuilder.lower(root.get("title")),
                        searchPattern
                ));
            }

            // 3. Filter by tag
            if (criteria.getTag() != null && !criteria.getTag().isBlank()) {
                Join<Note, NoteTag> noteTagJoin = root.join("noteTags", JoinType.INNER);
                Join<NoteTag, Tag> tagJoin = noteTagJoin.join("tag", JoinType.INNER);
                predicates.add(criteriaBuilder.equal(
                        criteriaBuilder.lower(tagJoin.get("label")),
                        criteria.getTag().toLowerCase()
                ));
            }

            return criteriaBuilder.and(predicates.toArray(new Predicate[0]));
        };

        // Sorting
        Sort.Direction direction = "asc".equalsIgnoreCase(criteria.getSortDirection())
                ? Sort.Direction.ASC
                : Sort.Direction.DESC;

        String sortBy = criteria.getSortBy() != null ? criteria.getSortBy() : "updatedAt";

        Pageable pageable = PageRequest.of(
                criteria.getPageNumber(),
                criteria.getPageSize(),
                Sort.by(direction, sortBy)
        );

        Page<Note> notesPage = noteRepository.findAll(spec, pageable);
        return notesPage.map(noteMapper::toResponse);
    }

    // Méthodes utilitaires privées

    private Note findNoteById(Long id) {
        return noteRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Note not found with id: " + id));
    }

    private void validateNoteOwnership(Note note, User user) {
        if (!note.getOwner().getId().equals(user.getId())) {
            throw new UnauthorizedException("You don't have permission to access this note");
        }
    }

    private void validateNoteAccess(Note note, User user) {
        // L'utilisateur peut accéder à la note s'il en est le propriétaire
        if (note.getOwner().getId().equals(user.getId())) {
            return;
        }

        // Ou si la note a été partagée avec lui
        boolean hasSharedAccess = shareRepository.existsByNoteAndSharedWithUser(note, user);

        if (hasSharedAccess) {
            return;
        }

        throw new UnauthorizedException("You don't have permission to access this note");
    }

    private void attachTagsToNote(Note note, List<String> tagLabels) {
        for (String label : tagLabels) {
            Tag tag = tagRepository.findByLabel(label)
                    .orElseGet(() -> {
                        Tag newTag = Tag.builder().label(label).build();
                        return tagRepository.save(newTag);
                    });

            NoteTag noteTag = NoteTag.builder()
                    .note(note)
                    .tag(tag)
                    .build();

            noteTagRepository.save(noteTag);
        }
    }
}
