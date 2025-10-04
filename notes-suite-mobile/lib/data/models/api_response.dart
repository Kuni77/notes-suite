class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final PageMetadata? metadata;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.metadata,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json,
      T Function(dynamic)? fromJsonT,
      ) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      metadata: json['metadata'] != null
          ? PageMetadata.fromJson(json['metadata'])
          : null,
    );
  }
}

class PageMetadata {
  final int currentPage;
  final int totalPages;
  final int totalElements;
  final int pageSize;
  final bool hasNext;
  final bool hasPrevious;

  PageMetadata({
    required this.currentPage,
    required this.totalPages,
    required this.totalElements,
    required this.pageSize,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PageMetadata.fromJson(Map<String, dynamic> json) {
    return PageMetadata(
      currentPage: json['currentPage'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
      pageSize: json['pageSize'] ?? 10,
      hasNext: json['hasNext'] ?? false,
      hasPrevious: json['hasPrevious'] ?? false,
    );
  }
}