package sn.notes.notessuitemodule.domain;

import jakarta.persistence.*;
import lombok.*;
import sn.notes.notessuitemodule.domain.audit.Auditable;

import java.util.ArrayList;
import java.util.List;

@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "tags")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Tag  extends Auditable<Integer> {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String label;

    @OneToMany(mappedBy = "tag", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<NoteTag> noteTags = new ArrayList<>();
}
