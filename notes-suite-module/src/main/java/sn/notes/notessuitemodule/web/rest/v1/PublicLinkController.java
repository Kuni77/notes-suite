package sn.notes.notessuitemodule.web.rest.v1;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import sn.notes.notessuitemodule.service.dto.NoteResponse;
import sn.notes.notessuitemodule.service.dto.PublicLinkResponse;
import sn.notes.notessuitemodule.service.dto.response.ApiResponse;
import sn.notes.notessuitemodule.service.interfaces.PublicLinkService;

import java.util.List;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
@Tag(name = "Public Links", description = "Public link management endpoints")
public class PublicLinkController {
    private final PublicLinkService publicLinkService;

    @PostMapping("/notes/{noteId}/share/public")
    @Operation(summary = "Create a public link for a note")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<ApiResponse<PublicLinkResponse>> createPublicLink(
            @PathVariable Long noteId,
            Authentication authentication) {
        String userEmail = authentication.getName();
        PublicLinkResponse publicLinkResponse = publicLinkService.createPublicLink(noteId, userEmail);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.<PublicLinkResponse>created()
                        .setData(publicLinkResponse)
                        .setMessage("Public link created successfully"));
    }

    @GetMapping("/notes/{noteId}/public-links")
    @Operation(summary = "Get all public links for a note")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<ApiResponse<List<PublicLinkResponse>>> getPublicLinksForNote(
            @PathVariable Long noteId,
            Authentication authentication) {
        String userEmail = authentication.getName();
        List<PublicLinkResponse> publicLinks = publicLinkService.getPublicLinksForNote(noteId, userEmail);
        return ResponseEntity.ok(
                ApiResponse.<List<PublicLinkResponse>>ok()
                        .setData(publicLinks)
                        .setMessage("Public links retrieved successfully"));
    }

    @GetMapping("/p/{urlToken}")
    @Operation(summary = "Get note by public token (no authentication required)")
    public ResponseEntity<ApiResponse<NoteResponse>> getNoteByPublicToken(@PathVariable String urlToken) {
        NoteResponse noteResponse = publicLinkService.getNoteByPublicToken(urlToken);
        return ResponseEntity.ok(
                ApiResponse.<NoteResponse>ok()
                        .setData(noteResponse)
                        .setMessage("Note retrieved successfully"));
    }

    @DeleteMapping("/public-links/{id}")
    @Operation(summary = "Delete a public link")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<ApiResponse<Void>> deletePublicLink(
            @PathVariable Long id,
            Authentication authentication) {
        String userEmail = authentication.getName();
        publicLinkService.deletePublicLink(id, userEmail);
        return ResponseEntity.ok(
                ApiResponse.<Void>ok()
                        .setMessage("Public link deleted successfully"));
    }
}
