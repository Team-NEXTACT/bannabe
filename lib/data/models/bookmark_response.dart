class BookmarkResponse {
  final bool success;
  final String message;
  final BookmarkData data;

  BookmarkResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory BookmarkResponse.fromJson(Map<String, dynamic> json) {
    return BookmarkResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: BookmarkData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class BookmarkData {
  final List<BookmarkStation> bookmarks;

  BookmarkData({
    required this.bookmarks,
  });

  factory BookmarkData.fromJson(Map<String, dynamic> json) {
    return BookmarkData(
      bookmarks: (json['bookmarks'] as List)
          .map((item) => BookmarkStation.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class BookmarkStation {
  final String name;
  final int stationId;
  final int bookmarkId;

  BookmarkStation({
    required this.name,
    required this.stationId,
    required this.bookmarkId,
  });

  factory BookmarkStation.fromJson(Map<String, dynamic> json) {
    return BookmarkStation(
      name: json['name'] as String,
      stationId: json['stationId'] as int,
      bookmarkId: json['bookmarkId'] as int,
    );
  }
}
