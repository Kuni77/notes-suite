package sn.notes.notessuitemodule.domain.audit;

import org.springframework.data.domain.AuditorAware;
import org.springframework.lang.NonNull;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import sn.notes.notessuitemodule.security.UserPrincipal;

import java.util.Optional;

public class AuditableImpl implements AuditorAware<Long> {
    @Override
    @NonNull
    public Optional<Long> getCurrentAuditor() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null || !authentication.isAuthenticated() ||
                authentication.getPrincipal().equals("anonymousUser")) {
            return Optional.empty();
        }

        Object principal = authentication.getPrincipal();

        // Si c'est notre UserPrincipal personnalisé
        if (principal instanceof UserPrincipal) {
            return Optional.of(((UserPrincipal) principal).getId());
        }

        return Optional.empty();
    }
}
