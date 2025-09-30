package sn.notes.notessuitemodule.service.dto;

import java.time.LocalDateTime;

public record PublicLinkResponse(
        Long id,
        Long noteId,
        String urlToken,
        String publicUrl,
        LocalDateTime expiresAt
) {}
