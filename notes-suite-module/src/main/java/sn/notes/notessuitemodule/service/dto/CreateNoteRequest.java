package sn.notes.notessuitemodule.service.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.util.List;

public record CreateNoteRequest(
        @NotBlank(message = "Title is required")
        @Size(min = 3, max = 255, message = "Title must be between 3 and 255 characters")
        String title,

        @Size(max = 50000, message = "Content must not exceed 50000 characters")
        String contentMd,

        List<String> tags
) {
    public CreateNoteRequest {
        if (tags == null) {
            tags = List.of();
        }
    }
}
