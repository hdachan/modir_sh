import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modir2/feed/views/screen1.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class WriteFeedScreen extends StatefulWidget {
  const WriteFeedScreen({super.key});

  @override
  State<WriteFeedScreen> createState() => _WriteFeedScreenState();
}

class _WriteFeedScreenState extends State<WriteFeedScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isContentEmpty = true;
  Color _completeButtonColor = const Color(0xFF888888);
  File? _image;
  Uint8List? _webImage;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_textFieldListener);
    _contentController.addListener(_textFieldListener);
  }

  void _textFieldListener() {
    setState(() {
      _isContentEmpty = _contentController.text.trim().isEmpty;
      _completeButtonColor = (_titleController.text.trim().isNotEmpty &&
          _contentController.text.trim().isNotEmpty)
          ? Colors.black
          : const Color(0xFF888888);
    });
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _webImage = bytes;
            _image = null;
          });
        } else {
          setState(() {
            _image = File(pickedFile.path);
            _webImage = null;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지가 선택되지 않았습니다')),
        );
      }
    } catch (e) {
      print('Image picker error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 선택 실패: $e')),
      );
    }
  }

  void _onCompletePressed(BuildContext context) async {
    final title = _titleController.text;
    final content = _contentController.text;

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 내용을 입력하세요')),
      );
      return;
    }

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인이 필요합니다')),
        );
        return;
      }

      Uint8List? imageBytes;
      if (_image != null) {
        imageBytes = await _image!.readAsBytes();
      } else if (_webImage != null) {
        imageBytes = _webImage;
      }

      // Test1 화면으로 데이터 전달 및 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Test1(
            title: title,
            content: content,
            imageBytes: imageBytes,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류 발생: $e')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 기존 build 메서드는 변경 없음
    return Scaffold(
      appBar: customAppBar(
        context,
        "글쓰기",
        _completeButtonColor,
            () => _onCompletePressed(context),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      height: 248,
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 24),
                      child: Stack(
                        children: [
                          Container(
                            width: 160,
                            height: 200,
                            decoration: ShapeDecoration(
                              color: _image == null && _webImage == null ? Colors.redAccent : null,
                              image: _image != null
                                  ? DecorationImage(
                                image: FileImage(_image!),
                                fit: BoxFit.cover,
                              )
                                  : _webImage != null
                                  ? DecorationImage(
                                image: MemoryImage(_webImage!),
                                fit: BoxFit.cover,
                              )
                                  : null,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          Positioned(
                            right: 12,
                            bottom: 12,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()..scale(-1.0, 1.0),
                                  child: const Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 20,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 56,
                    child: TextField(
                      controller: _titleController,
                      textAlign: TextAlign.left,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      decoration: const InputDecoration(
                        hintText: "제목을 입력해주세요",
                        hintStyle: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF888888),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Color(0xFF888888), width: 0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _contentController,
                          textAlign: TextAlign.left,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          maxLines: null,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                          decoration: const InputDecoration(
                            hintText: "내용을 입력해주세요",
                            hintStyle: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF888888),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 10),
                          ),
                        ),
                        if (_isContentEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: const Text(
                              '본 게시판의 사용 목적은 패션을 주제로 한 커뮤니티입니다.\n'
                                  '사용 목적이 옳바르지 않은 글을 게시하거나 시도한다면 서비스 사용이\n'
                                  '영구 제한 될 수도 있습니다.\n\n'
                                  '아래에는 이 게시판에 해당되는 핵심 내용에 대한 요약사항이며, 게시물 작성전 커뮤니티\n'
                                  '이용규칙 전문을 반드시 확인하시길 바랍니다.\n\n'
                                  '게시판에서 미리보기로 확인 가능한 텍스트는 첫 줄에 해당되는 텍스트입니다.\n'
                                  '게시판에서 미리보기로 확인 가능한 이미지는 처음 올리는 이미지 한 장입니다.\n\n'
                                  '• 정치·사회 관련 행위 금지\n'
                                  '• 홍보 및 판매 관련 행위 금지\n'
                                  '• 불법촬영물 유통 금지\n'
                                  '• 타인의 권리를 침해하거나 불쾌감을 주는 행위\n'
                                  '• 범죄, 불법 행위 등 법령을 위반하는 행위\n'
                                  '• 욕설, 비하, 차별, 혐오, 자살, 폭력 관련 내용 금지\n'
                                  '• 음란물, 성적, 수치심 유발 금지\n'
                                  '• 스포일러, 공포, 속임, 놀람 유도 금지',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF888888),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}

PreferredSizeWidget customAppBar(
    BuildContext context, String title, Color completeButtonColor, VoidCallback onCompletePressed) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(56),
    child: AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 0,
      title: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => context.go('/community'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              GestureDetector(
                onTap: onCompletePressed,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "완료",
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: completeButtonColor,
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
}

class SelectableTagList extends StatefulWidget {
  final List<String> tags;
  final Function(List<String>) onChanged;

  const SelectableTagList({
    super.key,
    required this.tags,
    required this.onChanged,
  });

  @override
  State<SelectableTagList> createState() => _SelectableTagListState();
}

class _SelectableTagListState extends State<SelectableTagList> {
  List<String> selectedTags = [];

  void toggleTag(String tag) {
    setState(() {
      if (selectedTags.contains(tag)) {
        selectedTags.remove(tag);
      } else {
        if (selectedTags.length < 3) {
          selectedTags.add(tag);
        }
      }
    });
    widget.onChanged(selectedTags);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.tags.map((tag) {
        final isSelected = selectedTags.contains(tag);
        return GestureDetector(
          onTap: () => toggleTag(tag),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.white,
            ),
            child: Text(
              tag,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: isSelected ? Colors.black : Color(0xff888888),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
