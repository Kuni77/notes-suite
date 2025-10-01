package sn.notes.notessuitemodule.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import sn.notes.notessuitemodule.domain.Note;
import sn.notes.notessuitemodule.domain.NoteTag;

import java.util.List;

public interface NoteTagRepository extends JpaRepository<NoteTag, Long> {
    List<NoteTag> findByNote(Note note);
    void deleteByNote(Note note);
}
