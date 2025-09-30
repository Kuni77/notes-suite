package sn.notes.notessuitemodule.domain.audit;

import jakarta.persistence.Column;
import jakarta.persistence.Temporal;
import jakarta.persistence.TemporalType;
import org.springframework.data.annotation.CreatedBy;
import org.springframework.data.annotation.LastModifiedBy;
import org.springframework.data.annotation.LastModifiedDate;

import java.sql.Timestamp;

public abstract class Auditable<T> {
    @CreatedBy
    @Column(name = "created_by", updatable = false)
    protected  T createdBy;

    @org.springframework.data.annotation.CreatedDate
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "created_at", updatable = false)
    protected Timestamp createdAt;

    @LastModifiedBy
    @Column(name = "modified_by")
    protected T lastModifiedBy;

    @LastModifiedDate
    @Column(name = "modified_at")
    protected Timestamp lastModifiedAt;
}
