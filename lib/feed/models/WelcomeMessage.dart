class WelcomeMessage {
  final int? id;
  final int? feedId;
  final String message;
  final DateTime createdAt;

  WelcomeMessage({
    this.id,
    this.feedId,
    required this.message,
    required this.createdAt,
  });

  factory WelcomeMessage.fromJson(Map<String, dynamic> json) {
    return WelcomeMessage(
      id: json['id'] as int?,
      feedId: json['feed_id'] as int?,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'feed_id': feedId,
      'message': message,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Category {
  final int? id;
  final int? feedId;
  final String userId;
  final String categoryName;
  final DateTime createdAt;

  Category({
    this.id,
    this.feedId,
    required this.userId,
    required this.categoryName,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int?,
      feedId: json['feed_id'] as int?,
      userId: json['user_id'] as String,
      categoryName: json['category_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'feed_id': feedId,
      'user_id': userId,
      'category_name': categoryName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}