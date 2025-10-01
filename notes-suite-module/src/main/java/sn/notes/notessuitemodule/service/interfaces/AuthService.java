package sn.notes.notessuitemodule.service.interfaces;

import sn.notes.notessuitemodule.service.dto.AuthResponse;
import sn.notes.notessuitemodule.service.dto.LoginRequest;
import sn.notes.notessuitemodule.service.dto.RefreshTokenRequest;
import sn.notes.notessuitemodule.service.dto.RegisterRequest;

public interface AuthService {
    AuthResponse register(RegisterRequest request);
    AuthResponse login(LoginRequest request);
    AuthResponse refreshToken(RefreshTokenRequest request);
}
