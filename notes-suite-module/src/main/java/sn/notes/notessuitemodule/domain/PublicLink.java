package sn.notes.notessuitemodule.domain;

import jakarta.persistence.*;
import lombok.*;
import sn.notes.notessuitemodule.domain.audit.Auditable;

import java.time.LocalDateTime;

@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "public_links")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PublicLink extends Auditable<Integer> {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "note_id", nullable = false)
    private Note note;

    @Column(unique = true, nullable = false)
    private String urlToken;

    private LocalDateTime expiresAt;
}
