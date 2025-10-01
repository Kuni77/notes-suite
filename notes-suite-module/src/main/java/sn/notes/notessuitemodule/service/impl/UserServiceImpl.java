package sn.notes.notessuitemodule.service.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import sn.notes.notessuitemodule.domain.User;
import sn.notes.notessuitemodule.exception.ResourceNotFoundException;
import sn.notes.notessuitemodule.repository.UserRepository;
import sn.notes.notessuitemodule.service.interfaces.UserService;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserServiceImpl implements UserService {
    private final UserRepository userRepository;

    @Override
    @Transactional(readOnly = true)
    public User findByEmail(String email) {
        log.debug("Finding user by email: {}", email);
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with email: " + email));
    }

    @Override
    @Transactional(readOnly = true)
    public boolean existsByEmail(String email) {
        log.debug("Checking if user exists with email: {}", email);
        return userRepository.existsByEmail(email);
    }

    @Override
    @Transactional
    public User createUser(String email, String passwordHash) {
        log.info("Creating user with email: {}", email);
        User user = User.builder()
                .email(email)
                .passwordHash(passwordHash)
                .build();
        return userRepository.save(user);
    }
}
