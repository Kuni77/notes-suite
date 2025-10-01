package sn.notes.notessuitemodule.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import sn.notes.notessuitemodule.domain.Tag;

import java.util.Optional;

public interface TagRepository extends JpaRepository<Tag, Long> {
    Optional<Tag> findByLabel(String label);
}
