/// Kiểm tra nhanh phía client, khớp với PlaceIdParser ở backend.
final _placeId = RegExp(r'^[A-Za-z0-9_-]{20,512}$');
final _placeIdInText = RegExp(r'place_?id[=:]([A-Za-z0-9_-]+)', caseSensitive: false);

const placeIdFinderUrl = 'https://developers.google.com/maps/documentation/places/web-service/place-id';

/// Lấy Place ID từ chuỗi người dùng dán vào (có thể là cả đường link chứa `placeid=`).
String extractPlaceId(String input) {
  final value = input.trim();
  return _placeIdInText.firstMatch(value)?.group(1) ?? value;
}

String? validatePlaceId(String? input) {
  final value = extractPlaceId(input ?? '');
  if (value.isEmpty) return 'Vui lòng nhập Google Place ID.';
  if (!_placeId.hasMatch(value)) {
    return 'Place ID sai định dạng. Place ID gồm chữ, số, dấu - hoặc _ và thường bắt đầu bằng "ChIJ".';
  }
  return null;
}

String buildReviewUrl(String placeId) => 'https://search.google.com/local/writereview?placeid=$placeId';

String? validateReviewUrl(String? input) {
  final value = input?.trim() ?? '';
  if (value.isEmpty) return null;
  final uri = Uri.tryParse(value);
  final host = uri?.host.toLowerCase() ?? '';
  final googleHost = ['google.com', 'g.page', 'goo.gl'].any((h) => host == h || host.endsWith('.$h'));
  if (uri == null || uri.scheme != 'https' || !googleHost) {
    return 'Link đánh giá phải là đường dẫn https của Google (google.com, g.page, goo.gl).';
  }
  return null;
}
