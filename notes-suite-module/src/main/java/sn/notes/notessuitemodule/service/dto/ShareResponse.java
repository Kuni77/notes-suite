package sn.notes.notessuitemodule.service.dto;

import sn.notes.notessuitemodule.domain.Permission;

public record ShareResponse(
        Long id,
        Long noteId,
        String sharedWithEmail,
        Permission permission
) {}
