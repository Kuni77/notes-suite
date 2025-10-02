package sn.notes.notessuitemodule.service.specification;

import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.JoinType;
import jakarta.persistence.criteria.Predicate;
import org.springframework.data.jpa.domain.Specification;
import sn.notes.notessuitemodule.domain.*;
import sn.notes.notessuitemodule.domain.enums.Visibility;

import java.util.ArrayList;
import java.util.List;

public class NoteSpecifications {
    public static Specification<Note> hasOwner(User owner) {
        return (root, query, criteriaBuilder) ->
                criteriaBuilder.equal(root.get("owner"), owner);
    }

    public static Specification<Note> titleContains(String query) {
        return (root, criteriaQuery, criteriaBuilder) -> {
            if (query == null || query.isBlank()) {
                return criteriaBuilder.conjunction();
            }
            return criteriaBuilder.like(
                    criteriaBuilder.lower(root.get("title")),
                    "%" + query.toLowerCase() + "%"
            );
        };
    }

    public static Specification<Note> hasVisibility(Visibility visibility) {
        return (root, query, criteriaBuilder) -> {
            if (visibility == null) {
                return criteriaBuilder.conjunction();
            }
            return criteriaBuilder.equal(root.get("visibility"), visibility);
        };
    }

    public static Specification<Note> hasTag(String tagLabel) {
        return (root, query, criteriaBuilder) -> {
            if (tagLabel == null || tagLabel.isBlank()) {
                return criteriaBuilder.conjunction();
            }

            Join<Note, NoteTag> noteTagJoin = root.join("noteTags", JoinType.LEFT);
            Join<NoteTag, Tag> tagJoin = noteTagJoin.join("tag", JoinType.LEFT);

            return criteriaBuilder.equal(tagJoin.get("label"), tagLabel);
        };
    }

    public static Specification<Note> searchWithFilters(
            User owner,
            String query,
            Visibility visibility,
            String tag) {

        return (root, criteriaQuery, criteriaBuilder) -> {
            List<Predicate> predicates = new ArrayList<>();

            // Owner obligatoire
            predicates.add(criteriaBuilder.equal(root.get("owner"), owner));

            // Recherche par titre
            if (query != null && !query.isBlank()) {
                predicates.add(criteriaBuilder.like(
                        criteriaBuilder.lower(root.get("title")),
                        "%" + query.toLowerCase() + "%"
                ));
            }

            // Filtre par visibilité
            if (visibility != null) {
                predicates.add(criteriaBuilder.equal(root.get("visibility"), visibility));
            }

            // Filtre par tag
            if (tag != null && !tag.isBlank()) {
                Join<Note, NoteTag> noteTagJoin = root.join("noteTags", JoinType.LEFT);
                Join<NoteTag, Tag> tagJoin = noteTagJoin.join("tag", JoinType.LEFT);
                predicates.add(criteriaBuilder.equal(tagJoin.get("label"), tag));
            }

            // Pour éviter les doublons avec les jointures
            if (criteriaQuery != null) {
                criteriaQuery.distinct(true);
            }

            return criteriaBuilder.and(predicates.toArray(new Predicate[0]));
        };
    }
}
