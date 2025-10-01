package sn.notes.notessuitemodule.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;
import sn.notes.notessuitemodule.service.dto.LoginRequest;
import sn.notes.notessuitemodule.service.dto.RegisterRequest;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
public class AuthControllerIT {
    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void register_WithValidData_ShouldReturnCreated() throws Exception {
        // Given
        RegisterRequest request = new RegisterRequest(
                "newuser@example.com",
                "password123"
        );

        // When & Then
        mockMvc.perform(post("/api/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.status").value(201))
                .andExpect(jsonPath("$.data.email").value("newuser@example.com"))
                .andExpect(jsonPath("$.data.accessToken").exists())
                .andExpect(jsonPath("$.data.refreshToken").exists())
                .andExpect(jsonPath("$.message").value("User registered successfully"));
    }

    @Test
    void register_WithInvalidEmail_ShouldReturnBadRequest() throws Exception {
        // Given
        RegisterRequest request = new RegisterRequest(
                "invalid-email",
                "password123"
        );

        // When & Then
        mockMvc.perform(post("/api/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.status").value(400))
                .andExpect(jsonPath("$.message").value("Validation failed"));
    }

    @Test
    void register_WithShortPassword_ShouldReturnBadRequest() throws Exception {
        // Given
        RegisterRequest request = new RegisterRequest(
                "user@example.com",
                "123"
        );

        // When & Then
        mockMvc.perform(post("/api/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.errors.password").exists());
    }

    @Test
    void login_WithValidCredentials_ShouldReturnOk() throws Exception {
        // Given - First register a user
        RegisterRequest registerRequest = new RegisterRequest(
                "logintest@example.com",
                "password123"
        );
        mockMvc.perform(post("/api/v1/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(registerRequest)));

        // When - Try to login
        LoginRequest loginRequest = new LoginRequest(
                "logintest@example.com",
                "password123"
        );

        // Then
        mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value(200))
                .andExpect(jsonPath("$.data.email").value("logintest@example.com"))
                .andExpect(jsonPath("$.data.accessToken").exists())
                .andExpect(jsonPath("$.message").value("Login successful"));
    }

    @Test
    void login_WithInvalidCredentials_ShouldReturnUnauthorized() throws Exception {
        // Given
        LoginRequest request = new LoginRequest(
                "nonexistent@example.com",
                "wrongpassword"
        );

        // When & Then
        mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.status").value(401));
    }
}
