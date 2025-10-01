package sn.notes.notessuitemodule.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import sn.notes.notessuitemodule.domain.Note;
import sn.notes.notessuitemodule.domain.User;
import sn.notes.notessuitemodule.service.specification.NoteSpecifications;

import java.util.List;

public interface NoteRepository extends JpaRepository<Note, Long>, JpaSpecificationExecutor<Note> {
    Page<Note> findByOwner(User owner, Pageable pageable);
}
