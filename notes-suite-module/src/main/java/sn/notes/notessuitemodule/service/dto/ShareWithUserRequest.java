package sn.notes.notessuitemodule.service.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public record ShareWithUserRequest(
        @NotBlank(message = "Email is required")
        @Email(message = "Email should be valid")
        String email
) {}
