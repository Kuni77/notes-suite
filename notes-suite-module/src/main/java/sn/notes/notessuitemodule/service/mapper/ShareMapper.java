package sn.notes.notessuitemodule.service.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import sn.notes.notessuitemodule.domain.Share;
import sn.notes.notessuitemodule.service.dto.ShareResponse;

import java.util.List;

@Mapper(componentModel = "spring")
public interface ShareMapper {

    @Mapping(source = "note.id", target = "noteId")
    @Mapping(source = "sharedWithUser.email", target = "sharedWithEmail")
    ShareResponse toResponse(Share share);

    List<ShareResponse> toResponseList(List<Share> shares);
}
