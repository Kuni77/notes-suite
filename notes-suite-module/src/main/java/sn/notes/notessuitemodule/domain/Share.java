package sn.notes.notessuitemodule.domain;

import jakarta.persistence.*;
import lombok.*;
import sn.notes.notessuitemodule.domain.audit.Auditable;

@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "shares")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Share extends Auditable<Integer> {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "note_id", nullable = false)
    private Note note;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shared_with_user_id", nullable = false)
    private User sharedWithUser;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private Permission permission = Permission.READ;
}
