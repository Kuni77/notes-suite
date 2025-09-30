package sn.notes.notessuitemodule.domain.audit;

import org.springframework.data.domain.AuditorAware;
import org.springframework.lang.NonNull;

import java.util.Optional;

public class AuditableImpl implements AuditorAware<Integer> {
    @Override
    @NonNull
    public Optional<Integer> getCurrentAuditor() {
        return Optional.empty();
    }
}
