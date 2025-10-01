package sn.notes.notessuitemodule.web.rest.v1;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import sn.notes.notessuitemodule.service.dto.ShareResponse;
import sn.notes.notessuitemodule.service.dto.ShareWithUserRequest;
import sn.notes.notessuitemodule.service.dto.response.ApiResponse;
import sn.notes.notessuitemodule.service.interfaces.ShareService;

import java.util.List;

@RestController
@RequestMapping("/api/v1/notes")
@RequiredArgsConstructor
@Tag(name = "Shares", description = "Note sharing endpoints")
@SecurityRequirement(name = "bearerAuth")
public class ShareController {
    private final ShareService shareService;

    @PostMapping("/{noteId}/share/user")
    @Operation(summary = "Share note with a user")
    public ResponseEntity<ApiResponse<ShareResponse>> shareNoteWithUser(
            @PathVariable Long noteId,
            @Valid @RequestBody ShareWithUserRequest request,
            Authentication authentication) {
        String userEmail = authentication.getName();
        ShareResponse shareResponse = shareService.shareNoteWithUser(noteId, request, userEmail);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.<ShareResponse>created()
                        .setData(shareResponse)
                        .setMessage("Note shared successfully"));
    }

    @GetMapping("/{noteId}/shares")
    @Operation(summary = "Get all shares for a note")
    public ResponseEntity<ApiResponse<List<ShareResponse>>> getSharesForNote(
            @PathVariable Long noteId,
            Authentication authentication) {
        String userEmail = authentication.getName();
        List<ShareResponse> shares = shareService.getSharesForNote(noteId, userEmail);
        return ResponseEntity.ok(
                ApiResponse.<List<ShareResponse>>ok()
                        .setData(shares)
                        .setMessage("Shares retrieved successfully"));
    }

    @DeleteMapping("/shares/{shareId}")
    @Operation(summary = "Remove a share")
    public ResponseEntity<ApiResponse<Void>> removeShare(
            @PathVariable Long shareId,
            Authentication authentication) {
        String userEmail = authentication.getName();
        shareService.removeShare(shareId, userEmail);
        return ResponseEntity.ok(
                ApiResponse.<Void>ok()
                        .setMessage("Share removed successfully"));
    }
}
