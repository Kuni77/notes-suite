package sn.notes.notessuitemodule.service.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.http.HttpStatus;

@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ApiResponse<T> {
    private int status;
    private T data;
    private String message;
    private Object errors;
    private PageMetadata metadata;

    public static <T> ApiResponse<T> ok() {
        ApiResponse<T> response = new ApiResponse<>();
        response.setStatus(HttpStatus.OK.value());
        return response;
    }

    public static <T> ApiResponse<T> created() {
        ApiResponse<T> response = new ApiResponse<>();
        response.setStatus(HttpStatus.CREATED.value());
        return response;
    }

    public static <T> ApiResponse<T> noContent() {
        ApiResponse<T> response = new ApiResponse<>();
        response.setStatus(HttpStatus.NO_CONTENT.value());
        return response;
    }

    public static <T> ApiResponse<T> badRequest() {
        ApiResponse<T> response = new ApiResponse<>();
        response.setStatus(HttpStatus.BAD_REQUEST.value());
        return response;
    }

    public static <T> ApiResponse<T> unauthorized() {
        ApiResponse<T> response = new ApiResponse<>();
        response.setStatus(HttpStatus.UNAUTHORIZED.value());
        return response;
    }

    public static <T> ApiResponse<T> forbidden() {
        ApiResponse<T> response = new ApiResponse<>();
        response.setStatus(HttpStatus.FORBIDDEN.value());
        return response;
    }

    public static <T> ApiResponse<T> notFound() {
        ApiResponse<T> response = new ApiResponse<>();
        response.setStatus(HttpStatus.NOT_FOUND.value());
        return response;
    }

    public static <T> ApiResponse<T> internalError() {
        ApiResponse<T> response = new ApiResponse<>();
        response.setStatus(HttpStatus.INTERNAL_SERVER_ERROR.value());
        return response;
    }

    // Méthodes pour le chaînage fluide
    public ApiResponse<T> setData(T data) {
        this.data = data;
        return this;
    }

    public ApiResponse<T> setMessage(String message) {
        this.message = message;
        return this;
    }

    public ApiResponse<T> setErrors(Object errors) {
        this.errors = errors;
        return this;
    }

    public ApiResponse<T> setMetadata(PageMetadata metadata) {
        this.metadata = metadata;
        return this;
    }
}
