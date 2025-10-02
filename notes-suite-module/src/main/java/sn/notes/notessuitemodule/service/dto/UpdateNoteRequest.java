package sn.notes.notessuitemodule.service.dto;

import jakarta.validation.constraints.Size;
import sn.notes.notessuitemodule.domain.enums.Visibility;

import java.util.List;

public record UpdateNoteRequest(
        @Size(min = 3, max = 255, message = "Title must be between 3 and 255 characters")
        String title,

        @Size(max = 50000, message = "Content must not exceed 50000 characters")
        String contentMd,

        Visibility visibility,

        List<String> tags
) {}