package sn.notes.notessuitemodule.service.dto;

public record AuthResponse(
        String accessToken,
        String refreshToken,
        String tokenType,
        String email
) {
    public AuthResponse(String accessToken, String refreshToken, String email) {
        this(accessToken, refreshToken, "Bearer", email);
    }
}
