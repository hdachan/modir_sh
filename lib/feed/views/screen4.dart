import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import 'screen3.dart';

class Screen4 extends StatefulWidget {
  final String itemName;
  final String? title;
  final String? content;
  final Uint8List? imageBytes;
  final List<String> categoryItems;
  final List<String> welcomeItems;
  final String? category;
  final int? index;

  const Screen4({
    Key? key,
    required this.itemName,
    this.title,
    this.content,
    this.imageBytes,
    required this.categoryItems,
    required this.welcomeItems,
    this.category,
    this.index,
  }) : super(key: key);

  @override
  State<Screen4> createState() => _Screen4State();
}

class _Screen4State extends State<Screen4> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  Color buttonColor = const Color(0xFF888888);

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.itemName;
    _contentController.text = ''; // 초기 내용은 빈 문자열
    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
    print('Screen4 initialized: itemName=${widget.itemName}');
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTextChanged);
    _contentController.removeListener(_onTextChanged);
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      buttonColor = _titleController.text.isEmpty || _contentController.text.isEmpty
          ? const Color(0xFF888888)
          : const Color(0xFF000000);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<Screen3ViewModel>(context);
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

    return Scaffold(
      appBar: customAppBar(
        context,
        '큐레이션 리스트 작성4',
        buttonColor,
            () async {
          if (userId.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('로그인이 필요합니다')),
            );
            return;
          }
          if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('제목과 내용을 입력해주세요')),
            );
            return;
          }
          print('Screen4 returning: title=${_titleController.text}, content=${_contentController.text}');
          context.pop({
            'title': _titleController.text,
            'content': _contentController.text,
          });
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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            hintText: '큐레이션 제목을 입력해주세요',
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
                          onChanged: (_) => _onTextChanged(),
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
              // Padding(
              //   padding: const EdgeInsets.only(bottom: 16),
              //   child: SizedBox(
              //     height: 140,
              //     child: SingleChildScrollView(
              //       scrollDirection: Axis.horizontal,
              //       child: Row(
              //         children: [
              //           const SizedBox(width: 16),
              //           if (widget.imageBytes != null)
              //             Padding(
              //               padding: const EdgeInsets.only(right: 8),
              //               child: ClipRRect(
              //                 borderRadius: BorderRadius.circular(8),
              //                 child: Image.memory(widget.imageBytes!, width: 160, height: 200, fit: BoxFit.cover),
              //               ),
              //             ),
              //           ...viewModel.images.map((image) => Padding(
              //             padding: const EdgeInsets.only(right: 8),
              //             child: ClipRRect(
              //               borderRadius: BorderRadius.circular(8),
              //               child: Image.memory(image, width: 160, height: 200, fit: BoxFit.cover),
              //             ),
              //           )),
              //           const SizedBox(width: 16),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
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