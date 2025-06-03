import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/Feedmodel.dart';

class FeedService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Feed>> fetchFeeds() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      final response = await _supabase
          .from('feed')
          .select('''
            feed_id, user_id, title, content, created_at, hits, status,
            userinfo: user_id (username),
            pic (pic_url),
            feed_like (user_id),
            sum_like: feed_like!feed_id (count)
          ''')
          .eq('status', 0)
          .order('created_at', ascending: false);

      return response.map((json) {
        final username = json['userinfo']['username'] ?? 'Unknown';
        final liked = userId != null &&
            json['feed_like'] != null &&
            (json['feed_like'] as List).any((like) => like['user_id'] == userId);
        final sumLike = json['sum_like'] != null ? json['sum_like'][0]['count'] : 0;

        return Feed.fromJson({
          ...json,
          'username': username,
          'liked': liked,
          'sum_like': sumLike,
        });
      }).toList();
    } catch (e) {
      print('Error fetching feeds: $e');
      return [];
    }
  }

  Future<Feed?> fetchFeedById(String feedId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      final response = await _supabase
          .from('feed')
          .select('''
            feed_id, user_id, title, content, created_at, hits, status,
            userinfo: user_id (username),
            pic (pic_url),
            feed_like (user_id),
            sum_like: feed_like!feed_id (count)
          ''')
          .eq('feed_id', feedId)
          .eq('status', 0)
          .single();

      final username = response['userinfo']['username'] ?? 'Unknown';
      final liked = userId != null &&
          response['feed_like'] != null &&
          (response['feed_like'] as List).any((like) => like['user_id'] == userId);
      final sumLike = response['sum_like'] != null ? response['sum_like'][0]['count'] : 0;

      return Feed.fromJson({
        ...response,
        'username': username,
        'liked': liked,
        'sum_like': sumLike,
      });
    } catch (e) {
      print('Error fetching feed: $e');
      return null;
    }
  }

  Future<int> addFeed(String userId, String title, String content, {Uint8List? imageBytes}) async {
    try {
      print('Adding feed for user: $userId');
      final feedResponse = await _supabase
          .from('feed')
          .insert({
        'user_id': userId,
        'title': title,
        'content': content,
        'created_at': DateTime.now().toIso8601String(),
        'hits': 0,
        'status': 0,
      })
          .select('feed_id')
          .single();
      final feedId = feedResponse['feed_id'] as int;
      print('Feed inserted: $feedId');

      if (imageBytes != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$userId.jpg';
        print('Uploading image to feedimages: $fileName');
        await _supabase.storage
            .from('feedimages')
            .uploadBinary(fileName, imageBytes, fileOptions: const FileOptions(contentType: 'image/jpeg'));
        final picUrl = _supabase.storage.from('feedimages').getPublicUrl(fileName);
        print('Image uploaded, URL: $picUrl');

        await _supabase.from('pic').insert({
          'feed_id': feedId,
          'pic_url': picUrl,
        });
        print('Pic table updated');
      }

      return feedId;
    } catch (e) {
      print('Error adding feed: $e');
      if (e is PostgrestException) {
        throw Exception('Database error: ${e.message}');
      } else if (e is StorageException) {
        throw Exception('Storage error: ${e.message}');
      }
      throw Exception('Failed to add feed: $e');
    }
  }

  Future<void> updateFeed(String feedId, String title, String content) async {
    try {
      await _supabase
          .from('feed')
          .update({
        'title': title,
        'content': content,
      })
          .eq('feed_id', feedId);
    } catch (e) {
      print('Error updating feed: $e');
      throw Exception('Failed to update feed: $e');
    }
  }

  Future<void> deleteFeed(String feedId) async {
    try {
      await _supabase
          .from('feed')
          .update({
        'status': 1,
      })
          .eq('feed_id', feedId);
    } catch (e) {
      print('Error updating feed status: $e');
      throw Exception('Failed to update feed status: $e');
    }
  }

  Future<void> toggleLike(String feedId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final existingLike = await _supabase
          .from('feed_like')
          .select()
          .eq('feed_id', feedId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingLike != null) {
        await _supabase
            .from('feed_like')
            .delete()
            .eq('feed_id', feedId)
            .eq('user_id', userId);
      } else {
        await _supabase
            .from('feed_like')
            .insert({'feed_id': feedId, 'user_id': userId});
      }
    } catch (e) {
      print('Error toggling like: $e');
      throw Exception('Failed to toggle like: $e');
    }
  }

  Future<void> incrementHits(String feedId) async {
    try {
      // 현재 hits 값 가져오기
      final response = await _supabase
          .from('feed')
          .select('hits')
          .eq('feed_id', feedId)
          .single();

      final currentHits = response['hits'] ?? 0;

      // hits 값 증가
      await _supabase
          .from('feed')
          .update({'hits': currentHits + 1})
          .eq('feed_id', feedId);
    } catch (e) {
      print('조회수 증가 중 오류 발생: $e');
      throw Exception('조회수 증가 실패: $e');
    }
  }

  Future<List<Feed>> fetchLikedFeeds() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('사용자가 로그인하지 않았습니다.');

      final response = await _supabase
          .from('feed_like')
          .select('''
            feed:feed_id (
              feed_id, user_id, title, content, created_at, hits, status,
              userinfo: user_id (username),
              pic (pic_url),
              feed_like (user_id),
              sum_like: feed_like!feed_id (count)
            )
          ''')
          .eq('user_id', userId)
          .eq('feed.status', 0) // 활성 상태의 피드만 조회
          .order('created_at', ascending: false, referencedTable: 'feed');

      return response.map((json) {
        final feedJson = json['feed'];
        final username = feedJson['userinfo']['username'] ?? 'Unknown';
        final liked = feedJson['feed_like'] != null &&
            (feedJson['feed_like'] as List).any((like) => like['user_id'] == userId);
        final sumLike = feedJson['sum_like'] != null ? feedJson['sum_like'][0]['count'] : 0;

        return Feed.fromJson({
          ...feedJson,
          'username': username,
          'liked': liked,
          'sum_like': sumLike,
        });
      }).toList();
    } catch (e) {
      print('좋아요한 피드 조회 중 오류: $e');
      return [];
    }
  }
}