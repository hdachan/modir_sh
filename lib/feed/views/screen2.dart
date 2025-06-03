import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:modir2/feed/views/screen3.dart';
import 'package:modir2/feed/views/screen4.dart';
import 'dart:typed_data';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Screen2 extends StatefulWidget {
  final String? title;
  final String? content;
  final Uint8List? imageBytes;
  final List<String> categoryItems;
  final List<String> welcomeItems;

  const Screen2({
    Key? key,
    this.title,
    this.content,
    this.imageBytes,
    required this.categoryItems,
    required this.welcomeItems,
  }) : super(key: key);

  @override
  State<Screen2> createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  String? selectedCategory;
  final Map<String, List<Map<String, String>>> curationMap = {};
  static const int maxCuration = 10;

  @override
  void initState() {
    super.initState();
    if (widget.categoryItems.isNotEmpty) {
      selectedCategory = widget.categoryItems.first;
      for (var cat in widget.categoryItems) {
        curationMap[cat] = [];
      }
    }
    print('Screen2 initialized: categories=${widget.categoryItems}, welcome=${widget.welcomeItems}');
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<Screen3ViewModel>(context);
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    final currentCurationList = selectedCategory != null
        ? curationMap[selectedCategory] ?? []
        : [];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: AppBar(
              backgroundColor: const Color(0xFFFFFFFF),
              elevation: 0,
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              title: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 24, color: Color(0xFF1C1B1F)),
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '모디챗 설정2',
                        style: const TextStyle(
                          color: Color(0xFF000000),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                  // Screen2.dart (_Screen2State의 build 메서드 내 AppBar의 TextButton 부분 수정)
                  TextButton(
                    onPressed: () async {
                      if (userId.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('로그인이 필요합니다')),
                        );
                        return;
                      }
                      // 필수 데이터 검증
                      if (widget.title == null || widget.title!.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('게시물 제목을 입력해주세요')),
                        );
                        return;
                      }
                      if (widget.content == null || widget.content!.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('게시물 내용을 입력해주세요')),
                        );
                        return;
                      }
                      if (widget.categoryItems.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('카테고리를 하나 이상 추가해주세요')),
                        );
                        return;
                      }
                      if (widget.welcomeItems.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('환영 메시지를 하나 이상 추가해주세요')),
                        );
                        return;
                      }
                      final hasValidCuration = curationMap.values.any((list) => list.isNotEmpty);
                      if (!hasValidCuration) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('큐레이션 리스트를 추가해주세요')),
                        );
                        return;
                      }
                      try {
                        print('Saving curationMap: $curationMap');
                        await viewModel.saveAll(
                          userId: userId,
                          title: widget.title ?? '',
                          content: widget.content ?? '',
                          categoryItems: widget.categoryItems,
                          welcomeItems: widget.welcomeItems,
                          curationMap: curationMap,
                          feedImageBytes: widget.imageBytes,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('저장되었습니다')),
                        );
                        context.go('/community');
                      } catch (e) {
                        print('Error saving curation: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('저장 실패: $e')),
                        );
                      }
                    },
                    child: const Text(
                      '완료',
                      style: TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: const Divider(
                color: Color(0xFFE7E7E7),
                thickness: 1,
                height: 0.5,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategorySelector(),
                    _buildDivider(),
                    _buildAddBox(
                      label: '큐레이션 리스트',
                      count: currentCurationList.length,
                      max: maxCuration,
                      onAdd: () async {
                        if (selectedCategory != null && currentCurationList.length < maxCuration) {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Screen4(
                                itemName: '', // 새로운 큐레이션이므로 빈 문자열
                                title: widget.title,
                                content: widget.content,
                                imageBytes: widget.imageBytes,
                                categoryItems: widget.categoryItems,
                                welcomeItems: widget.welcomeItems,
                                category: selectedCategory,
                                index: null, // 새로운 항목이므로 index 없음
                              ),
                            ),
                          );

                          if (result != null && result is Map<String, dynamic>) {
                            final newTitle = result['title'];
                            final newContent = result['content'];
                            if (newTitle is String && newContent is String) {
                              setState(() {
                                curationMap[selectedCategory!]!.add({
                                  'title': newTitle,
                                  'content': newContent,
                                });
                              });
                            }
                          }
                        }
                      },
                    ),
                    _buildDivider(),
                    for (int i = 0; i < currentCurationList.length; i++) ...[
                      _buildEditableBox(
                        text: currentCurationList[i]['title']!,
                        onEdit: () async {
                          print('Editing ${currentCurationList[i]['title']}: moving to Screen4');
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Screen4(
                                itemName: currentCurationList[i]['title']!,
                                title: widget.title,
                                content: widget.content,
                                imageBytes: widget.imageBytes,
                                categoryItems: widget.categoryItems,
                                welcomeItems: widget.welcomeItems,
                                category: selectedCategory,
                                index: i,
                              ),
                            ),
                          );

                          if (result != null && result is Map<String, dynamic>) {
                            final updatedTitle = result['title'];
                            final updatedContent = result['content'];
                            if (updatedTitle is String && updatedContent is String) {
                              setState(() {
                                curationMap[selectedCategory!]![i] = {
                                  'title': updatedTitle,
                                  'content': updatedContent,
                                };
                              });
                            }
                          }
                        },
                        onDelete: () {
                          setState(() {
                            currentCurationList.removeAt(i);
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFFFFFFF),
    );
  }

  Widget _buildCategorySelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: widget.categoryItems.map((cat) {
            final isSelected = selectedCategory == cat;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategory = cat;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFF6F6F6)
                      : const Color(0xFFFFFFFF),
                  border: Border.all(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  cat,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF3D3D3D),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAddBox({
    required String label,
    required int count,
    required int max,
    required VoidCallback onAdd,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: Color(0xFF000000),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text('$count/$max', style: const TextStyle(fontSize: 12)),
          ),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
              child: const Center(
                child: Icon(Icons.add, size: 12, color: Color(0xFF888888)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableBox({
    required String text,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Color(0xFF3D3D3D),
                  ),
                ),
              ),
              SizedBox(
                width: 24,
                height: 24,
                child: PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  iconSize: 12,
                  icon: const Icon(Icons.more_vert, size: 20),
                  color: const Color(0xFFE9EFF0),
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    else if (value == 'delete') onDelete();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('수정하기')),
                    PopupMenuItem(value: 'delete', child: Text('삭제하기')),
                  ],
                ),
              ),
            ],
          ),
        ),
        _buildDivider(),
      ],
    );
  }

  Widget _buildDivider() {
    return const Divider(color: Color(0xFFE7E7E7), thickness: 0.1, height: 0.1);
  }
}