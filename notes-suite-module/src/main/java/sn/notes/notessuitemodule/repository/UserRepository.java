package sn.notes.notessuitemodule.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import sn.notes.notessuitemodule.domain.User;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Integer> {
    Optional<User> findByEmail(String email);
}
