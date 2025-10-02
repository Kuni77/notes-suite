package sn.notes.notessuitemodule.service.dto;

import sn.notes.notessuitemodule.domain.enums.Visibility;

import java.time.LocalDateTime;
import java.util.List;

public record NoteResponse(
        Long id,
        String title,
        String contentMd,
        Visibility visibility,
        String ownerEmail,
        List<String> tags,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {}
