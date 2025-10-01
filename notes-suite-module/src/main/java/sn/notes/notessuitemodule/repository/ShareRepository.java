package sn.notes.notessuitemodule.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import sn.notes.notessuitemodule.domain.Note;
import sn.notes.notessuitemodule.domain.Share;
import sn.notes.notessuitemodule.domain.User;

import java.util.List;

public interface ShareRepository extends JpaRepository<Share, Long> {
    boolean existsByNoteAndSharedWithUser(Note note, User sharedWithUser);
    List<Share> findByNote(Note note);
}
