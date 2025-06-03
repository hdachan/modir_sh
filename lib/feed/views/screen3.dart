import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import '../sevices/FeedService.dart';
import '../sevices/supabase_service.dart';


class Screen3ViewModel with ChangeNotifier {
  final FeedService _feedService;
  final SupabaseService _supabaseService;
  List<Uint8List> _images = [];
  bool _isSaving = false;

  List<Uint8List> get images => _images;
  bool get isSaving => _isSaving;

  Screen3ViewModel(this._feedService, this._supabaseService);

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      _images.add(bytes);
      notifyListeners();
    }
  }

  Future<void> saveAll({
    required String userId,
    required String title,
    required String content,
    required List<String> categoryItems,
    required List<String> welcomeItems,
    String? curationTitle,
    String? curationContent,
    Map<String, List<Map<String, String>>>? curationMap,
    Uint8List? feedImageBytes,
  }) async {
    if (title.isEmpty || content.isEmpty || categoryItems.isEmpty || welcomeItems.isEmpty) {
      throw Exception('All required fields (title, content, categories, welcome messages) must be provided');
    }
    if ((curationTitle == null || curationContent == null) && (curationMap == null || curationMap.isEmpty)) {
      throw Exception('Curation data (either single curation or curation map) must be provided');
    }

    _isSaving = true;
    notifyListeners();

    try {
      // 피드 저장
      final feedId = await _feedService.addFeed(
        userId,
        title,
        content,
        imageBytes: feedImageBytes,
      );
      print('Feed saved with ID: $feedId');

      // 카테고리 저장 및 category_id 반환
      List<Map<String, dynamic>> categoryIds = await _supabaseService.insertCategories(categoryItems, userId, feedId);
      Map<String, int> categoryIdMap = {
        for (var cat in categoryIds) cat['category_name'] as String: cat['id'] as int
      };
      print('Categories inserted: $categoryItems, IDs: $categoryIdMap');

      // 환영 메시지 저장
      if (welcomeItems.isNotEmpty) {
        await _supabaseService.insertWelcomeMessages(welcomeItems, feedId);
        print('Welcome messages inserted: $welcomeItems');
      }

      // 이미지 업로드
      List<String> imageUrls = [];
      for (var image in _images) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$userId.jpg';
        await Supabase.instance.client.storage
            .from('curation_images')
            .uploadBinary(fileName, image, fileOptions: const FileOptions(contentType: 'image/jpeg'));
        final url = Supabase.instance.client.storage.from('curation_images').getPublicUrl(fileName);
        imageUrls.add(url);
      }
      print('Images uploaded: $imageUrls');

      // 큐레이션 저장
      if (curationContent != null && curationContent.isNotEmpty && curationTitle != null && categoryItems.isNotEmpty) {
        final categoryId = categoryIdMap[categoryItems.first];
        if (categoryId == null) {
          throw Exception('No valid category_id found for ${categoryItems.first}');
        }
        await _supabaseService.insertCurationList(
          feedId: feedId,
          title: curationTitle,
          content: curationContent,
          imageUrls: imageUrls,
          categoryId: categoryId,
        );
        print('Single curation inserted: $curationTitle, $curationContent, categoryId: $categoryId');
      } else if (curationMap != null) {
        final filteredMap = Map<String, List<Map<String, String>>>.fromEntries(
          curationMap.entries.where((entry) => entry.value.isNotEmpty),
        );
        if (filteredMap.isNotEmpty) {
          await _supabaseService.insertCurationLists(
            feedId: feedId,
            curationMap: filteredMap,
            imageUrls: imageUrls,
            categoryIds: categoryIdMap,
          );
          print('Curation lists inserted: $filteredMap');
        } else {
          print('No valid curation items to insert');
        }
      }
    } catch (e) {
      print('Error in saveAll: $e');
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void clear() {
    _images = [];
    _isSaving = false;
    notifyListeners();
  }
}

class Screen3 extends StatefulWidget {
  final String itemName;
  final String? title;
  final String? content;
  final Uint8List? imageBytes;
  final List<String> categoryItems;
  final List<String> welcomeItems;

  const Screen3({
    Key? key,
    required this.itemName,
    this.title,
    this.content,
    this.imageBytes,
    required this.categoryItems,
    required this.welcomeItems,
  }) : super(key: key);

  @override
  State<Screen3> createState() => _Screen3State();
}

class _Screen3State extends State<Screen3> {
  final TextEditingController _contentController = TextEditingController();
  Color buttonColor = const Color(0xFF888888);

  @override
  void initState() {
    super.initState();
    _contentController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _contentController.removeListener(_onTextChanged);
    _contentController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      buttonColor = _contentController.text.isEmpty
          ? const Color(0xFF888888)
          : const Color(0xFF000000);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<Screen3ViewModel>(context);
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

    return Scaffold(
// Screen3.dart (_Screen3State의 customAppBar 내 onCompletePressed 수정)
      appBar: customAppBar(
        context,
        '큐레이션 리스트',
        buttonColor,
            () async {
          if (userId.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('로그인이 필요합니다')),
            );
            return;
          }
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
          if (_contentController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('내용을 입력해주세요')),
            );
            return;
          }
          try {
            await viewModel.saveAll(
              userId: userId,
              title: widget.title ?? '',
              content: widget.content ?? '',
              categoryItems: widget.categoryItems,
              welcomeItems: widget.welcomeItems,
              curationTitle: widget.itemName,
              curationContent: _contentController.text,
              feedImageBytes: widget.imageBytes,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('저장되었습니다')),
            );
            context.go('/community');
          } catch (e) {
            print('Error saving: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('저장 실패: $e')),
            );
          }
        },
        buttonText: '완료',
        controller: _contentController,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(color: Color(0xFFE7E7E7), thickness: 5, height: 0.5),
                      _buildBlackBox('큐레이션 리스트'),
                      const Divider(color: Color(0xFFE7E7E7), thickness: 0.1, height: 0.1),
                      _buildGreyBox(widget.itemName),
                      const Divider(color: Color(0xFFE7E7E7), thickness: 0.1, height: 0.1),
                      _buildBlackBox('답변'),
                      const Divider(color: Color(0xFFE7E7E7), thickness: 0.1, height: 0.1),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: TextField(
                          controller: _contentController,
                          maxLines: null,
                          minLines: 10,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: const InputDecoration(
                            hintText: '내용을 입력해주세요',
                            hintStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF888888),
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SizedBox(
                  height: 140,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        ...viewModel.images.map((image) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(image, width: 160, height: 200, fit: BoxFit.cover),
                          ),
                        )),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(
                color: Color(0xFFE7E7E7),
                thickness: 1,
                height: 1,
                indent: 0,
                endIndent: 0,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: bottomBar(
          onImagePick: viewModel.pickImage,
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildGreyBox(String label) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Color(0xFF000000),
      ),
    ),
  );

  Widget _buildBlackBox(String label) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Color(0xFF000000),
      ),
    ),
  );
}

PreferredSizeWidget customAppBar(
    BuildContext context,
    String title,
    Color completeButtonColor,
    VoidCallback onCompletePressed, {
      String buttonText = '다음',
      required TextEditingController controller,
    }) =>
    PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: Container(
        color: Colors.white,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1C1B1F), size: 24),
                  onPressed: () {
                    if (controller.text.trim().isEmpty) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            backgroundColor: const Color(0xFFF0F0F0),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 280),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                                    child: Column(
                                      children: const [
                                        Text(
                                          '아직 큐레이션의 내용을 입력하지 않았어요 큐레이션 작성을 취소하시겠어요?',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF000000)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(color: Color(0xFFE0E0E0), thickness: 1, height: 1),
                                  SizedBox(
                                    height: 44,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            child: const Text('닫기', style: TextStyle(color: Color(0xFF3D3D3D), fontSize: 14)),
                                          ),
                                        ),
                                        Container(width: 1, color: Color(0xFFE0E0E0)),
                                        Expanded(
                                          child: TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('확인', style: TextStyle(color: Color(0xFF3D3D3D), fontSize: 14)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF000000),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: onCompletePressed,
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        buttonText,
                        style: TextStyle(
                          color: completeButtonColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

Widget bottomBar({required VoidCallback onImagePick}) => Container(
  height: 56,
  color: const Color(0xFFFFFFFF),
  padding: const EdgeInsets.all(8),
  child: Column(
    children: [
      Expanded(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: GestureDetector(
                  onTap: onImagePick,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: Color(0xFF3D3D3D),
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.all(8),
                child: GestureDetector(
                  onTap: onImagePick,
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: Color(0xFF3D3D3D),
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
);