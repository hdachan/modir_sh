import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/WelcomeMessage.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<WelcomeMessage>> fetchWelcomeMessages(int feedId) async {
    final response = await _supabase
        .from('welcome_messages')
        .select()
        .eq('feed_id', feedId);
    return (response as List<dynamic>)
        .map((json) => WelcomeMessage.fromJson(json))
        .toList();
  }

  Future<void> insertWelcomeMessages(List<String> messages, int feedId) async {
    final inserts = messages.map((message) => {
      'message': message,
      'feed_id': feedId,
      'created_at': DateTime.now().toIso8601String(),
    }).toList();
    if (inserts.isNotEmpty) {
      print('Inserting welcome messages: $inserts');
      await _supabase.from('welcome_messages').insert(inserts);
    }
  }

  Future<void> updateWelcomeMessage(int id, String newMessage, int feedId) async {
    await _supabase
        .from('welcome_messages')
        .update({'message': newMessage})
        .eq('id', id)
        .eq('feed_id', feedId);
  }

  Future<void> deleteWelcomeMessage(int id, int feedId) async {
    await _supabase
        .from('welcome_messages')
        .delete()
        .eq('id', id)
        .eq('feed_id', feedId);
  }

  Future<List<Category>> fetchCategories(String userId, int feedId) async {
    final response = await _supabase
        .from('categories')
        .select()
        .eq('user_id', userId)
        .eq('feed_id', feedId);
    return (response as List<dynamic>)
        .map((json) => Category.fromJson(json))
        .toList();
  }

  Future<List<Map<String, dynamic>>> insertCategories(List<String> categoryNames, String userId, int feedId) async {
    final List<Map<String, dynamic>> insertedCategories = [];
    for (var name in categoryNames) {
      final response = await _supabase
          .from('categories')
          .insert({
        'category_name': name,
        'user_id': userId,
        'feed_id': feedId,
        'created_at': DateTime.now().toIso8601String(),
      })
          .select('id, category_name')
          .single();
      insertedCategories.add(response);
    }
    print('Inserted categories: $insertedCategories');
    return insertedCategories;
  }

  Future<void> updateCategory(int id, String newCategoryName, String userId) async {
    await _supabase
        .from('categories')
        .update({'category_name': newCategoryName})
        .eq('id', id)
        .eq('user_id', userId);
  }

  Future<void> deleteCategory(int id, String userId) async {
    await _supabase
        .from('categories')
        .delete()
        .eq('id', id)
        .eq('user_id', userId);
  }

  Future<void> insertCurationList({
    required int feedId,
    required String title,
    required String content,
    required List<String> imageUrls,
    required int categoryId, // 추가
  }) async {
    final data = {
      'feed_id': feedId,
      'title': title,
      'content': content,
      'image_urls': imageUrls,
      'category_id': categoryId, // 추가
      'created_at': DateTime.now().toUtc().toIso8601String(),
    };
    print('Inserting curation list: $data');
    try {
      await _supabase.from('curation_lists').insert(data);
    } catch (e) {
      print('Error inserting curation list: $e');
      rethrow;
    }
  }

  Future<void> insertCurationLists({
    required int feedId,
    required Map<String, List<Map<String, String>>> curationMap,
    required List<String> imageUrls,
    required Map<String, int> categoryIds, // 추가: category_name -> category_id 매핑
  }) async {
    final inserts = [];
    for (var category in curationMap.keys) {
      final items = curationMap[category]!;
      if (items.isNotEmpty) {
        final categoryId = categoryIds[category];
        if (categoryId == null) {
          throw Exception('Category ID not found for category: $category');
        }
        for (var item in items) {
          inserts.add({
            'feed_id': feedId,
            'title': item['title'],
            'content': item['content'],
            'image_urls': imageUrls,
            'category_id': categoryId, // 추가
            'created_at': DateTime.now().toUtc().toIso8601String(),
          });
        }
      }
    }
    if (inserts.isEmpty) {
      print('No valid curation items to insert');
      return;
    }
    print('Inserting curation lists: $inserts');
    try {
      await _supabase.from('curation_lists').insert(inserts);
    } catch (e) {
      print('Error inserting curation lists: $e');
      rethrow;
    }
  }
}