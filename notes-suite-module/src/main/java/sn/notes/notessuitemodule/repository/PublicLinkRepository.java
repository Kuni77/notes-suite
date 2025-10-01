package sn.notes.notessuitemodule.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import sn.notes.notessuitemodule.domain.Note;
import sn.notes.notessuitemodule.domain.PublicLink;
import sn.notes.notessuitemodule.domain.User;

import java.util.List;
import java.util.Optional;

public interface PublicLinkRepository extends JpaRepository<PublicLink, Long> {
    List<PublicLink> findByNote(Note note);
    Optional<PublicLink> findByUrlToken(String urlToken);
}
