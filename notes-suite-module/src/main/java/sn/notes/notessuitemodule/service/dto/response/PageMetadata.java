package sn.notes.notessuitemodule.service.dto.response;

import org.springframework.data.domain.Page;

public record PageMetadata(
        int size,
        long totalElements,
        int totalPages,
        int number
) {
    public static PageMetadata from(Page<?> page) {
        return new PageMetadata(
                page.getSize(),
                page.getTotalElements(),
                page.getTotalPages(),
                page.getNumber()
        );
    }
}