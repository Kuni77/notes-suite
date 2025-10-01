package sn.notes.notessuitemodule.service.criteria;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import sn.notes.notessuitemodule.domain.Visibility;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NoteSearchCriteria {
    private String query;
    private Visibility visibility;
    private String tag;
    private Integer page;
    private Integer size;
    private String sortBy;
    private String sortDirection;

    public int getPageNumber() {
        return page != null && page >= 0 ? page : 0;
    }

    public int getPageSize() {
        return size != null && size > 0 && size <= 100 ? size : 10;
    }

    public String getSortField() {
        return sortBy != null && !sortBy.isBlank() ? sortBy : "updatedAt";
    }

    public String getSortOrder() {
        return sortDirection != null && sortDirection.equalsIgnoreCase("asc") ? "asc" : "desc";
    }
}
