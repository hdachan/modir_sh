import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Test5 extends StatefulWidget {
  final String feedId;

  const Test5({super.key, required this.feedId});

  @override
  State<Test5> createState() => _Test5State();
}
class _Test5State extends State<Test5> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        context,
        "모디챗",
        const Color(0xFFFFFFFF),
            () => print('Complete Pressed'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ChatBox(feedId: widget.feedId),
        ),
      ),
      backgroundColor: const Color(0xFFE7E7E7),
    );
  }
}

// 상단 바 위젯
PreferredSizeWidget customAppBar(
    BuildContext context,
    String title,
    Color completeButtonColor,
    VoidCallback onCompletePressed,
    ) {
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
                onTap: () => print("뒤로가기"),
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
                onTap: () => print("메뉴"),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: const Icon(
                    Icons.more_vert,
                    color: Colors.black,
                    size: 24,
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

class ChatBox extends StatefulWidget {
  final String feedId;

  const ChatBox({super.key, required this.feedId});

  @override
  State<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  final List<Map<String, dynamic>> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool showHintBox = false;
  Timer? _messageTimer;
  List<String> categoryOptions = [];
  String? selectedCategory; // 선택된 카테고리 이름
  int? selectedCategoryId; // 선택된 카테고리 ID
  List<String> curationTitles = []; // 선택된 카테고리의 title 목록
  bool awaitingConfirmation = false; // 확인 대기 상태 추가

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged); // 텍스트 변경 감지
    _loadCategories();
    _loadWelcomeMessages();
  }

  void _onTextChanged() {
    setState(() {
      showHintBox = _controller.text.contains('/');
      if (showHintBox && selectedCategoryId != null && awaitingConfirmation) {
        _loadCurationTitles(); // 항상 최신 데이터를 불러옴
      }
    });
  }

  void _loadCategories() async {
    try {
      final response = await Supabase.instance.client
          .from('categories')
          .select('id, category_name')
          .eq('feed_id', widget.feedId)
          .order('created_at', ascending: true);

      final categoryList = response as List<dynamic>;
      setState(() {
        categoryOptions = categoryList.map((item) => item['category_name'] as String).toList();
        if (categoryOptions.isNotEmpty && selectedCategory == null) {
          selectedCategory = categoryOptions[0]; // 첫 번째 카테고리 기본 선택
          selectedCategoryId = categoryList[0]['id'] as int;
        }
      });
    } catch (e) {
      print('Error loading categories: $e');
      setState(() {
        categoryOptions = [];
      });
    }
  }

  void _loadWelcomeMessages() async {
    try {
      final response = await Supabase.instance.client
          .from('welcome_messages')
          .select('message')
          .eq('feed_id', widget.feedId)
          .order('created_at', ascending: true);

      final messagesList = response as List<dynamic>;
      int index = 0;

      if (messagesList.isEmpty) {
        setState(() {
          messages.add({'text': '환영합니다! 채팅을 시작해보세요.', 'isMine': false});
        });
        _scrollToBottom();
        _addOptionsMessage();
        return;
      }

      _messageTimer = Timer.periodic(Duration(seconds: 2), (timer) {
        if (index >= messagesList.length) {
          timer.cancel();
          _addOptionsMessage();
          return;
        }

        setState(() {
          messages.add({
            'text': messagesList[index]['message'],
            'isMine': false,
          });
        });
        _scrollToBottom();
        index++;
      });
    } catch (e) {
      print('Error loading welcome messages: $e');
      setState(() {
        messages.add({'text': '메시지를 불러오지 못했습니다.', 'isMine': false});
      });
      _scrollToBottom();
      _addOptionsMessage();
    }
  }

  void _addOptionsMessage() {
    if (categoryOptions.isNotEmpty) {
      setState(() {
        messages.add({
          'type': 'options',
          'options': categoryOptions,
          'isMine': false,
          'isActive': true, // 메시지 활성화 상태 추가
        });
      });
      _scrollToBottom();
    }
  }

  void _loadCurationTitles() async {
    if (selectedCategoryId == null) return;
    try {
      final response = await Supabase.instance.client
          .from('curation_lists')
          .select('title')
          .eq('feed_id', widget.feedId)
          .eq('category_id', selectedCategoryId!)
          .order('created_at', ascending: true);

      final titleList = response as List<dynamic>;
      setState(() {
        curationTitles = titleList.map((item) => item['title'] as String).toList();
      });
    } catch (e) {
      print('Error loading curation titles: $e');
      setState(() {
        curationTitles = [];
      });
    }
  }

  void _selectOption(String option, int messageIndex) async {
    final categoryId = await _getCategoryId(option);
    setState(() {
      // 이전 옵션 메시지 비활성화
      for (var msg in messages) {
        if (msg['type'] == 'options') {
          msg['isActive'] = false;
        }
      }
      selectedCategory = option; // 카테고리 이름 업데이트
      selectedCategoryId = categoryId; // 해당 카테고리의 ID 가져오기
      messages.add({'text': option, 'isMine': true});
      awaitingConfirmation = true; // 확인 대기 상태로 전환
      messages.add({
        'text': '혹시 잘못 선택하셨나요? \n다시 고르고 싶다면 아래의 버튼을 눌러주세요',
        'isMine': false,
        'type': 'confirmation',
      });
      messages.add({
        'type': 'confirmation_options',
        'options': ['다시 고르기'],
        'isMine': false,
        'isActive': true, // 확인 옵션 활성화
      });
    });
    _scrollToBottom();
  }

  Future<int?> _getCategoryId(String categoryName) async {
    final response = await Supabase.instance.client
        .from('categories')
        .select('id')
        .eq('category_name', categoryName)
        .eq('feed_id', widget.feedId)
        .maybeSingle();
    if (response is Map<String, dynamic>) {
      return response['id'] as int?;
    }
    return null;
  }

  void _selectConfirmationOption(String option) {
    setState(() {
      print('Messages before update: $messages'); // 디버깅 로그
      // 이전 확인 옵션 메시지 비활성화
      for (var msg in messages) {
        if (msg['type'] == 'confirmation_options') {
          msg['isActive'] = false;
        }
      }
      if (option == '선택한 카테고리가 맞아요') {
        messages.add({'text': '알겠습니다! /를 입력하여 큐레이션을 선택해주세요.', 'isMine': false});
        awaitingConfirmation = false;
        curationTitles.clear();
      } else if (option == '다시 고르기') {
        messages.add({'text': '카테고리를 다시 선택해주세요.', 'isMine': false});
        _addOptionsMessage();
        awaitingConfirmation = false;
        curationTitles.clear();
      }
      print('Messages after update: $messages'); // 디버깅 로그
    });
    _scrollToBottom();
  }

  void _selectTitle(String title) {
    _loadCurationContent(title);
    setState(() {
      _controller.clear(); // / 입력 후 선택 후 입력창 초기화
      showHintBox = false;
      curationTitles.clear(); // title 목록 초기화
    });
    _scrollToBottom();
  }

  void _loadCurationContent(String title) async {
    try {
      final response = await Supabase.instance.client
          .from('curation_lists')
          .select('content')
          .eq('feed_id', widget.feedId)
          .eq('title', title)
          .limit(1)
          .single();

      final content = response['content'] as String;
      setState(() {
        messages.add({'text': content, 'isMine': false});
      });
      _scrollToBottom();
    } catch (e) {
      print('Error loading curation content: $e');
      setState(() {
        messages.add({'text': '콘텐츠를 불러오지 못했습니다.', 'isMine': false});
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    String text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({'text': text, 'isMine': true});
      _controller.clear();
      showHintBox = false;
    });
    _scrollToBottom();
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Color(0xFFE7E7E7),
            padding: const EdgeInsets.only(top: 24, left: 14, right: 14, bottom: 12),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isFirstOfPartner =
                    !msg['isMine'] && (index == 0 || messages[index - 1]['isMine']);

                return Align(
                  alignment: msg['isMine'] ? Alignment.centerRight : Alignment.centerLeft,
                  child: msg['isMine']
                      ? _buildMyMessage(msg['text'])
                      : _buildPartnerMessage(
                    msg,
                    isFirstOfPartner,
                    index,
                    onSelectOption: _selectOption,
                    onSelectConfirmation: awaitingConfirmation ? _selectConfirmationOption : null,
                  ),
                );
              },
            ),
          ),
        ),
        if (showHintBox && curationTitles.isNotEmpty)
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: curationTitles.map((title) {
                return GestureDetector(
                  onTap: () => _selectTitle(title),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFFE7E7E7), width: 1),
                    ),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        if (showHintBox && curationTitles.isEmpty)
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '카테고리를 선택한 후 /를 입력하세요!',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                    decoration: const InputDecoration(
                      hintText: '/를 통해 큐레이션 리스트를 확인하세요',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                      ),
                      filled: true,
                      fillColor: Color(0xFFE7E7E7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      isDense: true,
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: Color(0xFFE7E7E7),
                  borderRadius: BorderRadius.all(Radius.circular(100)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Color(0xff888888)),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// 모디 채팅 UX 위젯
Widget _buildPartnerMessage(
    Map<String, dynamic> msg,
    bool isFirst,
    int index, {
      required void Function(String option, int messageIndex) onSelectOption,
      void Function(String option)? onSelectConfirmation,
    }) {
  String? text;
  bool isImage = false;
  bool isImageList = false;
  bool isOptions = false;
  bool isConfirmation = false;
  bool isConfirmationOptions = false;
  String? singleImagePath;
  List<String>? imagePaths;
  List<String>? options;
  bool isActive = msg['isActive'] ?? false; // 메시지 활성화 여부 확인

  if (msg['type'] == 'image' && msg['image'] != null) {
    isImage = true;
    singleImagePath = msg['image'];
  } else if (msg['type'] == 'images' && msg['images'] != null) {
    isImageList = true;
    imagePaths = List<String>.from(msg['images']);
  } else if (msg['type'] == 'options' && msg['options'] != null) {
    isOptions = true;
    options = List<String>.from(msg['options']);
  } else if (msg['type'] == 'confirmation' && msg['text'] != null) {
    isConfirmation = true;
    text = msg['text'];
  } else if (msg['type'] == 'confirmation_options' && msg['options'] != null) {
    isConfirmationOptions = true;
    options = List<String>.from(msg['options']);
  } else if (msg['text'] is String) {
    text = msg['text'];
  }

  // 비활성화된 confirmation_options 메시지를 렌더링하지 않음
  if (isConfirmationOptions && !isActive) {
    return const SizedBox.shrink(); // 비활성화된 "다시 고르기" 버튼 숨김
  }

  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (isFirst)
        Container(
          width: 36,
          height: 36,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: const Color(0xffC4C4C4),
            borderRadius: BorderRadius.circular(4),
          ),
        )
      else
        const SizedBox(width: 44),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isFirst)
            const Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Text(
                '모디',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: (isImage || isImageList || isOptions || isConfirmationOptions)
                ? EdgeInsets.zero
                : const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.zero,
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: isImage
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                singleImagePath!,
                width: 140,
                height: 140,
                fit: BoxFit.cover,
              ),
            )
                : isImageList
                ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(8),
              child: Row(
                children: imagePaths!
                    .map((path) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      path,
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                    ),
                  ),
                ))
                    .toList(),
              ),
            )
                : isOptions
                ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Column(
                children: options!.asMap().entries.map((entry) {
                  int idx = entry.key;
                  String option = entry.value;
                  return GestureDetector(
                    onTap: isActive
                        ? () => onSelectOption(option, index)
                        : null, // 비활성화 시 클릭 불가
                    child: Container(
                      width: 200,
                      margin: EdgeInsets.only(
                        bottom: idx < (options?.length ?? 0) - 1 ? 8 : 0,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.white : Colors.grey[200], // 비활성화 시 회색 배경
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE7E7E7), width: 1),
                      ),
                      child: Text(
                        option,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: isActive ? Colors.black : Colors.grey, // 비활성화 시 회색 텍스트
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            )
                : isConfirmationOptions && onSelectConfirmation != null
                ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Column(
                children: options!.asMap().entries.map((entry) {
                  int idx = entry.key;
                  String option = entry.value;
                  return GestureDetector(
                    onTap: isActive
                        ? () => onSelectConfirmation(option)
                        : null, // 비활성화 시 클릭 불가
                    child: Container(
                      width: 200,
                      margin: EdgeInsets.only(
                        bottom: idx < (options?.length ?? 0) - 1 ? 8 : 0,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.white : Colors.grey[300], // 비활성화 시 더 진한 회색
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE7E7E7), width: 1),
                      ),
                      child: Opacity(
                        opacity: isActive ? 1.0 : 0.5, // 비활성화 시 투명도 조정
                        child: Text(
                          option,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: isActive ? Colors.black : Colors.grey[600], // 비활성화 시 회색 텍스트
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            )
                : Text(
              text ?? '',
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

// 사용자 채팅 UX 위젯
Widget _buildMyMessage(String text) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 2),
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    decoration: BoxDecoration(
      color: const Color(0xff3D3D3D),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.zero,
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
    ),
  );
}