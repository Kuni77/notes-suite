package sn.notes.notessuitemodule.service.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import sn.notes.notessuitemodule.domain.PublicLink;
import sn.notes.notessuitemodule.service.dto.PublicLinkResponse;

import java.util.List;

@Mapper(componentModel = "spring")
public interface PublicLinkMapper {
    @Mapping(source = "note.id", target = "noteId")
    @Mapping(target = "publicUrl", expression = "java(buildPublicUrl(publicLink.getUrlToken()))")
    PublicLinkResponse toResponse(PublicLink publicLink);

    List<PublicLinkResponse> toResponseList(List<PublicLink> publicLinks);

    default String buildPublicUrl(String urlToken) {
        return "/api/v1/p/" + urlToken;
    }

}
