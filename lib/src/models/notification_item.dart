class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.titleRu,
    required this.titleUz,
    required this.bodyRu,
    required this.bodyUz,
    required this.imageUrl,
    required this.isRead,
    required this.createdAt,
  });

  final int id;
  final String titleRu;
  final String titleUz;
  final String bodyRu;
  final String bodyUz;
  final String? imageUrl;
  final bool isRead;
  final DateTime? createdAt;

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: _asInt(json['id']),
      titleRu: _asString(json['title_ru']),
      titleUz: _asString(json['title_uz']),
      bodyRu: _asString(json['body_ru']),
      bodyUz: _asString(json['body_uz']),
      imageUrl: _asNullableString(json['image_url']),
      isRead: _asBool(json['is_read']),
      createdAt: _asDate(json['created_at']),
    );
  }
}

int _asInt(Object? value) => value is num ? value.toInt() : 0;

String _asString(Object? value) => value?.toString() ?? '';

String? _asNullableString(Object? value) {
  final text = value?.toString();
  if (text == null || text.isEmpty) return null;
  return text;
}

bool _asBool(Object? value) => value == true || value == 1;

DateTime? _asDate(Object? value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
