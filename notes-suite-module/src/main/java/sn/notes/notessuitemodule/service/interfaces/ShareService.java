package sn.notes.notessuitemodule.service.interfaces;

import sn.notes.notessuitemodule.domain.Note;
import sn.notes.notessuitemodule.domain.Share;
import sn.notes.notessuitemodule.domain.User;
import sn.notes.notessuitemodule.service.dto.ShareResponse;
import sn.notes.notessuitemodule.service.dto.ShareWithUserRequest;

import java.util.List;

public interface ShareService {
    ShareResponse shareNoteWithUser(Long noteId, ShareWithUserRequest request, String ownerEmail);
    List<ShareResponse> getSharesForNote(Long noteId, String userEmail);
    void removeShare(Long shareId, String userEmail);
    boolean hasAccessToNote(Long noteId, String userEmail);
}
