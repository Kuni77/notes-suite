package sn.notes.notessuitemodule.service.interfaces;

import sn.notes.notessuitemodule.service.dto.NoteResponse;
import sn.notes.notessuitemodule.service.dto.PublicLinkResponse;

import java.util.List;

public interface PublicLinkService {
    PublicLinkResponse createPublicLink(Long noteId, String userEmail);
    List<PublicLinkResponse> getPublicLinksForNote(Long noteId, String userEmail);
    NoteResponse getNoteByPublicToken(String urlToken);
    void deletePublicLink(Long publicLinkId, String userEmail);
}
