import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:modir2/feed/views/screen1.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../Mypage/views/modirchat.dart';
import '../viewmodels/FeedViewModel.dart';
import '../models/Feedmodel.dart';

class FeedDetailScreen extends StatefulWidget {
  final String feedId;

  const FeedDetailScreen({super.key, required this.feedId});

  @override
  State<FeedDetailScreen> createState() => _FeedDetailScreenState();
}

class _FeedDetailScreenState extends State<FeedDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<FeedViewModel>(context, listen: false);
      viewModel.fetchFeedById(widget.feedId);
    });
  }

  void _showEditDialog(BuildContext context, FeedViewModel viewModel) {
    final feed = viewModel.feeds.firstWhere(
          (f) => f.feedId == widget.feedId,
      orElse: () => Feed(
        feedId: '',
        userId: '',
        username: '',
        title: '',
        content: '',
        createdAt: DateTime.now(),
        hits: 0,
        status: 0,
        liked: false,
        sumLike: 0,
      ),
    );
    final titleController = TextEditingController(text: feed.title);
    final contentController = TextEditingController(text: feed.content);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "게시물 수정",
          style: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w500),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: "제목을 입력해주세요",
                hintStyle: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  color: Color(0xFF888888),
                ),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontFamily: 'Pretendard', fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                hintText: "내용을 입력해주세요",
                hintStyle: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  color: Color(0xFF888888),
                ),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              style: const TextStyle(fontFamily: 'Pretendard', fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "취소",
              style: TextStyle(fontFamily: 'Pretendard', color: Color(0xFF888888)),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.isEmpty || contentController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('제목과 내용을 입력하세요')),
                );
                return;
              }
              try {
                await viewModel.updateFeed(
                  widget.feedId,
                  titleController.text,
                  contentController.text,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('게시물이 수정되었습니다')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('수정 실패: $e')),
                );
              }
            },
            child: const Text(
              "저장",
              style: TextStyle(fontFamily: 'Pretendard', color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, FeedViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "숨김 확인",
          style: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w500),
        ),
        content: const Text("이 게시물을 숨기시겠습니까?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "취소",
              style: TextStyle(fontFamily: 'Pretendard', color: Color(0xFF888888)),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await viewModel.deleteFeed(widget.feedId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('게시물이 숨겨졌습니다')),
                );
                context.go('/community');
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('숨김 실패: $e')),
                );
              }
            },
            child: const Text(
              "숨기기",
              style: TextStyle(fontFamily: 'Pretendard', color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLikeAndCommentSection(BuildContext context, Feed feed, FeedViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              await viewModel.toggleLike(widget.feedId);
            },
            child: Icon(
              feed.liked ? Icons.favorite : Icons.favorite_border,
              color: feed.liked ? Colors.red : Colors.black,
              size: 24,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            "${feed.sumLike}",
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: customAppBar(
        context,
        "게시글",
        Colors.black,
            () {},
        leadingIcon: Icons.arrow_back_ios_new,
        onLeadingPressed: () => context.go('/community'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {},
              child: const Icon(Icons.ios_share, size: 24, color: Colors.black),
            ),
          ),
          Consumer<FeedViewModel>(
            builder: (context, viewModel, _) {
              final feed = viewModel.feeds.firstWhere(
                    (f) => f.feedId == widget.feedId,
                orElse: () => Feed(
                  feedId: '',
                  userId: '',
                  username: '',
                  title: '',
                  content: '',
                  createdAt: DateTime.now(),
                  hits: 0,
                  status: 0,
                  liked: false,
                  sumLike: 0,
                ),
              );
              final isAuthor = userId != null && feed.userId == userId;

              return isAuthor
                  ? PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditDialog(context, viewModel);
                  } else if (value == 'delete') {
                    _showDeleteDialog(context, viewModel);
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text(
                      '수정하기',
                      style: TextStyle(fontFamily: 'Pretendard'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      '삭제하기',
                      style: TextStyle(fontFamily: 'Pretendard'),
                    ),
                  ),
                ],
                icon: const Icon(Icons.more_vert, color: Colors.black),
              )
                  : const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<FeedViewModel>(
        builder: (context, viewModel, _) {
          final feed = viewModel.feeds.firstWhere(
                (f) => f.feedId == widget.feedId,
            orElse: () => Feed(
              feedId: '',
              userId: '',
              username: '',
              title: '',
              content: '',
              createdAt: DateTime.now(),
              hits: 0,
              status: 0,
              liked: false,
              sumLike: 0,
            ),
          );

          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (feed.feedId.isEmpty) {
            return const Center(child: Text("게시글을 찾을 수 없습니다."));
          }

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 사용자 정보
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: ShapeDecoration(
                            color: Colors.cyan,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                feed.username,
                                style: const TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${feed.createdAt.toIso8601String().substring(0, 10)} ${feed.createdAt.hour}:${feed.createdAt.minute.toString().padLeft(2, '0')}",
                                style: const TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF888888),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 대표 이미지
                  if (feed.picUrl != null)
                    Container(
                      width: double.infinity,
                      height: 200,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(feed.picUrl!),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) => const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                  // 사진이 있을 경우 좋아요/댓글 섹션
                  if (feed.picUrl != null) _buildLikeAndCommentSection(context, feed, viewModel),
                  // 제목 및 내용
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feed.title,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          feed.content,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF3D3D3D),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 사진이 없을 경우 좋아요/댓글 섹션
                  if (feed.picUrl == null) _buildLikeAndCommentSection(context, feed, viewModel),

                  /// 👉 하단 버튼 수정
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Test5(feedId: feed.feedId), // Test1 대신 Test5로 변경
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        decoration: ShapeDecoration(
                          color: const Color(0xFF3D3D3D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '시작하기',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w500,
                            height: 1.40,
                            letterSpacing: -0.35,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// 커스텀 AppBar
PreferredSizeWidget customAppBar(
    BuildContext context,
    String title,
    Color completeButtonColor,
    VoidCallback onCompletePressed, {
      IconData leadingIcon = Icons.arrow_back_ios_new,
      VoidCallback? onLeadingPressed,
      List<Widget> actions = const [],
    }) {
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
                onTap: onLeadingPressed ?? () => context.go('/community'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Icon(
                    leadingIcon,
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
              Row(
                children: [
                  ...actions,
                  if (onCompletePressed != () {})
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
            ],
          ),
        ),
      ),
    ),
  );
}