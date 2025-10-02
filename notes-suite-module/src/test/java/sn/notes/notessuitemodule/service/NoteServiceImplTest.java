package sn.notes.notessuitemodule.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import sn.notes.notessuitemodule.domain.Note;
import sn.notes.notessuitemodule.domain.User;
import sn.notes.notessuitemodule.domain.enums.Visibility;
import sn.notes.notessuitemodule.exception.ResourceNotFoundException;
import sn.notes.notessuitemodule.repository.NoteRepository;
import sn.notes.notessuitemodule.repository.NoteTagRepository;
import sn.notes.notessuitemodule.repository.TagRepository;
import sn.notes.notessuitemodule.service.dto.CreateNoteRequest;
import sn.notes.notessuitemodule.service.dto.NoteResponse;
import sn.notes.notessuitemodule.service.impl.NoteServiceImpl;
import sn.notes.notessuitemodule.service.interfaces.UserService;
import sn.notes.notessuitemodule.service.mapper.NoteMapper;

import java.time.LocalDateTime;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class NoteServiceImplTest {
    @Mock
    private NoteRepository noteRepository;

    @Mock
    private UserService userService;

    @Mock
    private TagRepository tagRepository;

    @Mock
    private NoteTagRepository noteTagRepository;

    @Mock
    private NoteMapper noteMapper;

    @InjectMocks
    private NoteServiceImpl noteService;

    private User testUser;
    private Note testNote;
    private CreateNoteRequest createRequest;
    private NoteResponse noteResponse;

    @BeforeEach
    void setUp() {
        testUser = User.builder()
                .id(1L)
                .email("test@example.com")
                .passwordHash("hashedPassword")
                .build();

        testNote = Note.builder()
                .id(1L)
                .title("Test Note")
                .contentMd("# Test Content")
                .visibility(Visibility.PRIVATE)
                .owner(testUser)
                .build();

        createRequest = new CreateNoteRequest(
                "Test Note",
                "# Test Content",
                List.of("test", "demo")
        );

        noteResponse = new NoteResponse(
                1L,
                "Test Note",
                "# Test Content",
                Visibility.PRIVATE,
                "test@example.com",
                List.of("test", "demo"),
                LocalDateTime.now(),
                LocalDateTime.now()
        );
    }

    @Test
    void createNote_ShouldCreateNoteSuccessfully() {
        // Given
        when(userService.findByEmail("test@example.com")).thenReturn(testUser);
        when(noteRepository.save(any(Note.class))).thenReturn(testNote);
        when(noteMapper.toResponse(testNote)).thenReturn(noteResponse);

        // When
        NoteResponse result = noteService.createNote(createRequest, "test@example.com");

        // Then
        assertNotNull(result);
        assertEquals("Test Note", result.title());
        assertEquals("# Test Content", result.contentMd());
        verify(userService, times(1)).findByEmail("test@example.com");
        verify(noteRepository, times(1)).save(any(Note.class));
        verify(noteMapper, times(1)).toResponse(any(Note.class));
    }

    @Test
    void createNote_WithInvalidUser_ShouldThrowException() {
        // Given
        when(userService.findByEmail("invalid@example.com"))
                .thenThrow(new ResourceNotFoundException("User not found"));

        // When & Then
        assertThrows(ResourceNotFoundException.class,
                () -> noteService.createNote(createRequest, "invalid@example.com"));

        verify(noteRepository, never()).save(any(Note.class));
    }

    @Test
    void deleteNote_ShouldDeleteNoteSuccessfully() {
        // Given
        when(noteRepository.findById(1L)).thenReturn(java.util.Optional.of(testNote));
        when(userService.findByEmail("test@example.com")).thenReturn(testUser);
        doNothing().when(noteRepository).delete(testNote);

        // When
        noteService.deleteNote(1L, "test@example.com");

        // Then
        verify(noteRepository, times(1)).findById(1L);
        verify(noteRepository, times(1)).delete(testNote);
    }
}
