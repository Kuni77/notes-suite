package sn.notes.notessuitemodule.service.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import sn.notes.notessuitemodule.exception.BadRequestException;
import sn.notes.notessuitemodule.security.JwtTokenProvider;
import sn.notes.notessuitemodule.service.dto.AuthResponse;
import sn.notes.notessuitemodule.service.dto.LoginRequest;
import sn.notes.notessuitemodule.service.dto.RefreshTokenRequest;
import sn.notes.notessuitemodule.service.dto.RegisterRequest;
import sn.notes.notessuitemodule.service.interfaces.AuthService;
import sn.notes.notessuitemodule.service.interfaces.UserService;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthServiceImpl implements AuthService {
    private final UserService userService;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider tokenProvider;
    private final AuthenticationManager authenticationManager;

    @Override
    @Transactional
    public AuthResponse register(RegisterRequest request) {
        log.info("Registering new user with email: {}", request.email());

        if (userService.existsByEmail(request.email())) {
            throw new BadRequestException("Email already exists");
        }

        userService.createUser(request.email(), passwordEncoder.encode(request.password()));

        String accessToken = tokenProvider.generateAccessToken(request.email());
        String refreshToken = tokenProvider.generateRefreshToken(request.email());

        log.info("User registered successfully: {}", request.email());

        return new AuthResponse(accessToken, refreshToken, request.email());
    }

    @Override
    public AuthResponse login(LoginRequest request) {
        log.info("User login attempt: {}", request.email());

        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.email(),
                        request.password()
                )
        );

        String accessToken = tokenProvider.generateAccessToken(authentication);
        String refreshToken = tokenProvider.generateRefreshToken(request.email());

        log.info("User logged in successfully: {}", request.email());

        return new AuthResponse(accessToken, refreshToken, request.email());
    }

    @Override
    public AuthResponse refreshToken(RefreshTokenRequest request) {
        log.info("Refreshing token");

        if (!tokenProvider.validateToken(request.refreshToken())) {
            throw new BadRequestException("Invalid refresh token");
        }

        String email = tokenProvider.getEmailFromToken(request.refreshToken());

        if (!userService.existsByEmail(email)) {
            throw new BadRequestException("User not found");
        }

        String newAccessToken = tokenProvider.generateAccessToken(email);
        String newRefreshToken = tokenProvider.generateRefreshToken(email);

        log.info("Token refreshed successfully for user: {}", email);

        return new AuthResponse(newAccessToken, newRefreshToken, email);
    }
}
