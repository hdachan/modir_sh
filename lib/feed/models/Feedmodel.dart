class Feed {
  final String feedId;
  final String userId;
  final String username;
  final String title;
  final String content;
  final DateTime createdAt;
  final int hits;
  final int status;
  final String? picUrl;
  final bool liked; // 추가: 현재 사용자가 좋아요 눌렀는지
  final int sumLike; // 추가: 총 좋아요 수

  Feed({
    required this.feedId,
    required this.userId,
    required this.username,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.hits,
    required this.status,
    this.picUrl,
    this.liked = false,
    this.sumLike = 0,
  });

  factory Feed.fromJson(Map<String, dynamic> json) {
    final picUrl = json['pic'] != null && (json['pic'] as List).isNotEmpty
        ? json['pic'][0]['pic_url']
        : null;

    // 좋아요 상태 및 개수 처리
    final liked = json['liked'] ?? false;
    final sumLike = json['sum_like'] ?? 0;

    return Feed(
      feedId: json['feed_id'].toString(),
      userId: json['user_id'],
      username: json['userinfo']['username'] ?? 'Unknown',
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      hits: json['hits'] ?? 0,
      status: json['status'] ?? 0,
      picUrl: picUrl,
      liked: liked,
      sumLike: sumLike,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'feed_id': feedId,
      'user_id': userId,
      'username': username,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'hits': hits,
      'status': status,
      'pic_url': picUrl,
      'liked': liked,
      'sum_like': sumLike,
    };
  }
}