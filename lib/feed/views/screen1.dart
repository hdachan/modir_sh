import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import '../../widget/write_widget.dart';
import '../sevices/supabase_service.dart';
import 'screen2.dart';

class Test1ViewModel with ChangeNotifier {
  final SupabaseService _service;
  List<String> _welcomeItems = [];
  List<String> _categoryItems = [];
  static const int maxWelcome = 3;
  static const int maxCategory = 5;

  List<String> get welcomeItems => _welcomeItems;
  List<String> get categoryItems => _categoryItems;

  Test1ViewModel(this._service);

  void addWelcomeMessage(String message) {
    if (_welcomeItems.length < maxWelcome) {
      _welcomeItems.add(message);
      notifyListeners();
    }
  }

  void updateWelcomeMessage(int index, String newText) {
    if (index >= 0 && index < _welcomeItems.length) {
      _welcomeItems[index] = newText;
      notifyListeners();
    }
  }

  void deleteWelcomeMessage(int index) {
    if (index >= 0 && index < _welcomeItems.length) {
      _welcomeItems.removeAt(index);
      notifyListeners();
    }
  }

  void addCategory(String categoryName) {
    if (_categoryItems.length < maxCategory) {
      _categoryItems.add(categoryName);
      notifyListeners();
    }
  }

  void updateCategory(int index, String newText) {
    if (index >= 0 && index < _categoryItems.length) {
      _categoryItems[index] = newText;
      notifyListeners();
    }
  }

  void deleteCategory(int index) {
    if (index >= 0 && index < _categoryItems.length) {
      _categoryItems.removeAt(index);
      notifyListeners();
    }
  }

  void clear() {
    _welcomeItems = [];
    _categoryItems = [];
    notifyListeners();
    print('Test1ViewModel cleared: welcomeItems=$_welcomeItems, categoryItems=$_categoryItems');
  }
}

class Test1 extends StatefulWidget {
  final String? title;
  final String? content;
  final Uint8List? imageBytes;

  const Test1({
    super.key,
    this.title,
    this.content,
    this.imageBytes,
  });

  @override
  State<Test1> createState() => _Test1State();
}

class _Test1State extends State<Test1> {
  @override
  void initState() {
    super.initState();
    // 화면 진입 시 ViewModel 초기화
    Provider.of<Test1ViewModel>(context, listen: false).clear();
  }

  Future<void> _showEditDialog({
    required String initialText,
    required ValueChanged<String> onConfirm,
  }) async {
    final controller = TextEditingController(text: initialText);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFE9EFF0),
        title: const Text('내용 수정'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            fillColor: Colors.white,
            filled: true,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          TextButton(
            onPressed: () {
              onConfirm(controller.text);
              Navigator.pop(context);
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<Test1ViewModel>(context);

    return Scaffold(
      body: Column(
        children: [
          writeTopBar(),
          buildTopDivider(),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    buildAddBox(
                      label: '환영 메시지',
                      count: viewModel.welcomeItems.length,
                      max: Test1ViewModel.maxWelcome,
                      onAdd: () {
                        viewModel.addWelcomeMessage('안녕하세요');
                      },
                    ),
                    for (int i = 0; i < viewModel.welcomeItems.length; i++)
                      buildEditableBox(
                        text: viewModel.welcomeItems[i],
                        onEdit: () => _showEditDialog(
                          initialText: viewModel.welcomeItems[i],
                          onConfirm: (newText) => viewModel.updateWelcomeMessage(i, newText),
                        ),
                        onDelete: () => viewModel.deleteWelcomeMessage(i),
                      ),
                    buildAddBox(
                      label: '카테고리 추가',
                      count: viewModel.categoryItems.length,
                      max: Test1ViewModel.maxCategory,
                      onAdd: () {
                        viewModel.addCategory('카테고리 ${viewModel.categoryItems.length + 1}');
                      },
                    ),
                    for (int i = 0; i < viewModel.categoryItems.length; i++)
                      buildEditableBox(
                        text: viewModel.categoryItems[i],
                        onEdit: () => _showEditDialog(
                          initialText: viewModel.categoryItems[i],
                          onConfirm: (newText) => viewModel.updateCategory(i, newText),
                        ),
                        onDelete: () => viewModel.deleteCategory(i),
                      ),
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

  Widget writeTopBar() {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: Color(0xFF1C1B1F), size: 24),
                ),
                const Spacer(),
                const Text(
                  "모디챗 설정1",
                  style: TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    final viewModel = Provider.of<Test1ViewModel>(context, listen: false);

                    if (viewModel.welcomeItems.isEmpty || viewModel.categoryItems.isEmpty) {
                      // Snackbar 표시
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('환영 메시지와 카테고리를 모두 하나 이상 입력해주세요.'),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    // 정상 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Screen2(
                          title: widget.title,
                          content: widget.content,
                          imageBytes: widget.imageBytes,
                          categoryItems: viewModel.categoryItems,
                          welcomeItems: viewModel.welcomeItems,
                        ),
                      ),
                    );
                  },


                  child: const Text(
                    "다음",
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
    );
  }
}