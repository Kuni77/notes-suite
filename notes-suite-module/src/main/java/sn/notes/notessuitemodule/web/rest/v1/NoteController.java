package sn.notes.notessuitemodule.web.rest.v1;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import sn.notes.notessuitemodule.domain.enums.Visibility;
import sn.notes.notessuitemodule.service.criteria.NoteSearchCriteria;
import sn.notes.notessuitemodule.service.dto.CreateNoteRequest;
import sn.notes.notessuitemodule.service.dto.NoteResponse;
import sn.notes.notessuitemodule.service.dto.UpdateNoteRequest;
import sn.notes.notessuitemodule.service.dto.response.ApiResponse;
import sn.notes.notessuitemodule.service.dto.response.PageMetadata;
import sn.notes.notessuitemodule.service.interfaces.NoteService;

import java.util.List;

@RestController
@RequestMapping("/notes")
@RequiredArgsConstructor
@Tag(name = "Notes", description = "Notes management endpoints")
@SecurityRequirement(name = "bearerAuth")
public class NoteController {
    private final NoteService noteService;

    @PostMapping
    @Operation(summary = "Create a new note")
    public ResponseEntity<ApiResponse<NoteResponse>> createNote(
            @Valid @RequestBody CreateNoteRequest request,
            Authentication authentication) {
        String userEmail = authentication.getName();
        NoteResponse noteResponse = noteService.createNote(request, userEmail);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.<NoteResponse>created()
                        .setData(noteResponse)
                        .setMessage("Note created successfully"));
    }

    @GetMapping
    @Operation(summary = "Search and filter notes with pagination")
    public ResponseEntity<ApiResponse<List<NoteResponse>>> searchNotes(
            @RequestParam(required = false) String query,
            @RequestParam(required = false) Visibility visibility,
            @RequestParam(required = false) String tag,
            @RequestParam(defaultValue = "0") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(defaultValue = "updatedAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDirection,
            Authentication authentication) {

        String userEmail = authentication.getName();

        NoteSearchCriteria criteria = NoteSearchCriteria.builder()
                .query(query)
                .visibility(visibility)
                .tag(tag)
                .page(page)
                .size(size)
                .sortBy(sortBy)
                .sortDirection(sortDirection)
                .build();

        Page<NoteResponse> notesPage = noteService.searchNotes(criteria, userEmail);

        return ResponseEntity.ok(
                ApiResponse.<List<NoteResponse>>ok()
                        .setData(notesPage.getContent())
                        .setMetadata(PageMetadata.from(notesPage))
                        .setMessage("Notes retrieved successfully"));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get note by ID")
    public ResponseEntity<ApiResponse<NoteResponse>> getNoteById(
            @PathVariable Long id,
            Authentication authentication) {
        String userEmail = authentication.getName();
        NoteResponse noteResponse = noteService.getNoteById(id, userEmail);
        return ResponseEntity.ok(
                ApiResponse.<NoteResponse>ok()
                        .setData(noteResponse)
                        .setMessage("Note retrieved successfully"));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update note")
    public ResponseEntity<ApiResponse<NoteResponse>> updateNote(
            @PathVariable Long id,
            @Valid @RequestBody UpdateNoteRequest request,
            Authentication authentication) {
        String userEmail = authentication.getName();
        NoteResponse noteResponse = noteService.updateNote(id, request, userEmail);
        return ResponseEntity.ok(
                ApiResponse.<NoteResponse>ok()
                        .setData(noteResponse)
                        .setMessage("Note updated successfully"));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete note")
    public ResponseEntity<ApiResponse<Void>> deleteNote(
            @PathVariable Long id,
            Authentication authentication) {
        String userEmail = authentication.getName();
        noteService.deleteNote(id, userEmail);
        return ResponseEntity.ok(
                ApiResponse.<Void>ok()
                        .setMessage("Note deleted successfully"));
    }
}
