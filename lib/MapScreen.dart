import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:modir2/widget/test_widget.dart';
import 'package:provider/provider.dart';

import 'feed/viewmodels/FeedViewModel.dart';
import 'feed/models/Feedmodel.dart';
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = FeedViewModel();
        viewModel.fetchFeeds();
        return viewModel;
      },
      child: Consumer<FeedViewModel>(
        builder: (context, viewModel, child) {
          final screenWidth = MediaQuery.of(context).size.width;
          final crossAxisCount = screenWidth > 600 ? 3 : 2;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Scaffold(
                body: Column(
                  children: [
                    customAppBar(),
                    customBodyBar(context, "공지"),
                    Expanded(
                      child: viewModel.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : viewModel.feeds.isEmpty
                          ? const Center(child: Text('피드가 없습니다.'))
                          : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: screenWidth > 600 ? 0.6 : 0.55,
                        ),
                        itemCount: viewModel.feeds.length,
                        itemBuilder: (context, index) {
                          Feed feed = viewModel.feeds[index];
                          return Card2(feed: feed);
                        },
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.white,
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    context.go('/community/write');
                  },
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.edit, color: Colors.white),
                  tooltip: '글쓰기',
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class Card2 extends StatefulWidget {
  final Feed feed;

  const Card2({super.key, required this.feed});

  @override
  _Card2State createState() => _Card2State();
}

class _Card2State extends State<Card2> {
  late GoRouter _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _router = GoRouter.of(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 360;
    final fontSizeTitle = isSmallScreen ? 11.0 : 12.0;
    final fontSizeContent = isSmallScreen ? 13.0 : 14.0;
    final fontSizeFooter = isSmallScreen ? 11.0 : 12.0;
    final imageHeight = isSmallScreen ? 160.0 : 180.0;

    return GestureDetector(
      onTap: () async {
        final viewModel = Provider.of<FeedViewModel>(context, listen: false);
        try {
          await viewModel.incrementHits(widget.feed.feedId, refresh: false);
          if (mounted) {
            _router.go('/community/detail/${widget.feed.feedId}');
          }
        } catch (e) {
          print('카드 탭 처리 중 오류: $e');
        }
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFF6F6F6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 14,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.feed.username,
                      style: TextStyle(
                        color: const Color(0xFF888888),
                        fontSize: 12,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                        height: 1.20,
                        letterSpacing: -0.30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7E7E7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      '광고',
                      style: TextStyle(
                        color: const Color(0xFF888888),
                        fontSize: 8,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                        height: 1.20,
                        letterSpacing: -0.20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: imageHeight,
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: widget.feed.picUrl != null
                      ? NetworkImage(widget.feed.picUrl!)
                      : const AssetImage('assets/image/cat.png') as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(
              height: 40,
              child: Text(
                widget.feed.title,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: fontSizeContent,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _formatCreatedAt(widget.feed.createdAt),
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: fontSizeFooter,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF888888),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.visibility_outlined,
                    color: Color(0xFF888888),
                    size: 12,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${widget.feed.hits}',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: fontSizeFooter,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF888888),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCreatedAt(DateTime createdAt) {
    try {
      final now = DateTime.now();
      final difference = now.difference(createdAt);

      if (difference.inDays < 7) {
        if (difference.inMinutes < 1) {
          return '방금 전';
        } else if (difference.inMinutes < 60) {
          return '${difference.inMinutes}분 전';
        } else if (difference.inHours < 24) {
          return '${difference.inHours}시간 전';
        } else {
          return '${difference.inDays}일 전';
        }
      } else {
        return DateFormat('yyyy-MM-dd').format(createdAt);
      }
    } catch (e) {
      print('createdAt 파싱 오류: $e');
      return createdAt.toString();
    }
  }
}