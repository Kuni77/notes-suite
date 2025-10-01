package sn.notes.notessuitemodule.service.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Named;
import sn.notes.notessuitemodule.domain.Note;
import sn.notes.notessuitemodule.domain.NoteTag;
import sn.notes.notessuitemodule.service.dto.NoteResponse;

import java.util.List;
import java.util.stream.Collectors;

@Mapper(componentModel = "spring")
public interface NoteMapper {

    @Mapping(source = "owner.email", target = "ownerEmail")
    @Mapping(source = "noteTags", target = "tags", qualifiedByName = "noteTagsToStrings")
    NoteResponse toResponse(Note note);

    List<NoteResponse> toResponseList(List<Note> notes);

    @Named("noteTagsToStrings")
    default List<String> noteTagsToStrings(List<NoteTag> noteTags) {
        if (noteTags == null) {
            return List.of();
        }
        return noteTags.stream()
                .map(noteTag -> noteTag.getTag().getLabel())
                .collect(Collectors.toList());
    }
}
