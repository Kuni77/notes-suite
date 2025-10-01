package sn.notes.notessuitemodule.service.interfaces;

import sn.notes.notessuitemodule.domain.User;

public interface UserService {
    User findByEmail(String email);
    boolean existsByEmail(String email);
    User createUser(String email, String passwordHash);
}
