package sn.notes.notessuitemodule.service.interfaces;

import org.springframework.data.domain.Page;
import sn.notes.notessuitemodule.service.criteria.NoteSearchCriteria;
import sn.notes.notessuitemodule.service.dto.CreateNoteRequest;
import sn.notes.notessuitemodule.service.dto.NoteResponse;
import sn.notes.notessuitemodule.service.dto.UpdateNoteRequest;

public interface NoteService {
    NoteResponse createNote(CreateNoteRequest request, String userEmail);
    Page<NoteResponse> searchNotes(NoteSearchCriteria criteria, String userEmail);
    NoteResponse getNoteById(Long id, String userEmail);
    NoteResponse updateNote(Long id, UpdateNoteRequest request, String userEmail);
    void deleteNote(Long id, String userEmail);
    Page<NoteResponse> getSharedNotes(NoteSearchCriteria criteria, String userEmail);
}
