import 'package:flutter/material.dart';
import 'package:flutterapp/models/post_model.dart';
import 'package:flutterapp/screens/board/board_write_screen.dart';
import 'package:flutterapp/services/board_service.dart';

class BoardDetailScreen extends StatefulWidget {
  final Post post;

  const BoardDetailScreen({super.key, required this.post});

  @override
  State<BoardDetailScreen> createState() => _BoardDetailScreenState();
}

class _BoardDetailScreenState extends State<BoardDetailScreen> {
  late Post _currentPost;
  final BoardService _boardService = BoardService();

  @override
  void initState() {
    super.initState();
    _currentPost = widget.post;
  }

  Future<void> _deletePost() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('게시글 삭제'),
        content: const Text('정말로 이 게시글을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _boardService.deletePost(id: _currentPost.id);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  Widget _buildTagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글 상세'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BoardWriteScreen(post: _currentPost),
                ),
              );
              if (result == true) {
                // TODO: 게시글 수정 후 상세 페이지를 다시 불러와야 함
                // 현재는 더미 데이터를 사용하므로 수정한 내용이 자동으로 반영되지 않을 수 있습니다.
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deletePost,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '[${_currentPost.category}]',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentPost.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _currentPost.author,
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  _currentPost.createdAt,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.remove_red_eye_outlined, size: 16),
                const SizedBox(width: 4),
                Text('${_currentPost.views}'),
                const SizedBox(width: 16),
                const Icon(Icons.thumb_up_outlined, size: 16),
                const SizedBox(width: 4),
                Text('${_currentPost.likes}'),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _currentPost.tags.map((tag) => _buildTagChip(tag)).toList(),
            ),
            const Divider(height: 32),
            Text(
              _currentPost.content,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
