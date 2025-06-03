import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../sevices/FeedService.dart';
import '../models/Feedmodel.dart';

class FeedViewModel extends ChangeNotifier {
  final FeedService _feedService = FeedService();
  List<Feed> feeds = [];
  List<Feed> likedFeeds = []; // 좋아요한 피드 저장용 리스트 추가
  Feed? selectedFeed; // 기존에 selectedFeed가 없었으므로 추가
  bool isLoading = false;

  Future<void> fetchFeeds() async {
    isLoading = true;
    notifyListeners();
    feeds = await _feedService.fetchFeeds();
    isLoading = false;
    notifyListeners();
  }

  Future<Feed?> fetchFeedById(String feedId) async {
    isLoading = true;
    notifyListeners();
    final feed = await _feedService.fetchFeedById(feedId);
    if (feed != null) {
      selectedFeed = feed; // 선택된 피드 저장
      final index = feeds.indexWhere((f) => f.feedId == feedId);
      if (index != -1) {
        feeds[index] = feed;
      } else {
        feeds.add(feed);
      }
    }
    isLoading = false;
    notifyListeners();
    return feed;
  }

  Future<void> loadLikedFeeds() async {
    isLoading = true;
    notifyListeners();
    likedFeeds = await _feedService.fetchLikedFeeds();
    isLoading = false;
    notifyListeners();
  }

  Future<void> addFeed(String userId, String title, String content, {Uint8List? imageBytes}) async {
    await _feedService.addFeed(userId, title, content, imageBytes: imageBytes);
    await fetchFeeds();
    await loadLikedFeeds(); // 피드 추가 후 좋아요 목록 갱신
  }

  Future<void> updateFeed(String feedId, String title, String content) async {
    await _feedService.updateFeed(feedId, title, content);
    await fetchFeedById(feedId);
    await loadLikedFeeds(); // 피드 수정 후 좋아요 목록 갱신
  }

  Future<void> deleteFeed(String feedId) async {
    await _feedService.deleteFeed(feedId);
    await fetchFeeds();
    await loadLikedFeeds(); // 피드 삭제 후 좋아요 목록 갱신
  }

  Future<void> toggleLike(String feedId) async {
    await _feedService.toggleLike(feedId);
    await fetchFeedById(feedId);
    await loadLikedFeeds(); // 좋아요 토글 후 좋아요 목록 갱신
  }

  Future<void> incrementHits(String feedId, {bool refresh = true}) async {
    await _feedService.incrementHits(feedId);
    if (refresh) {
      await fetchFeedById(feedId);
    }
  }
}