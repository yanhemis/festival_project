import 'package:flutter/material.dart';
import 'package:flutterapp/models/post_model.dart';
import 'package:flutterapp/services/board_service.dart';

class BoardWriteScreen extends StatefulWidget {
  final Post? post;

  const BoardWriteScreen({super.key, this.post});

  @override
  State<BoardWriteScreen> createState() => _BoardWriteScreenState();
}

class _BoardWriteScreenState extends State<BoardWriteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final BoardService _boardService = BoardService();
  String _selectedCategory = '자유 게시판'; // 기본 카테고리 설정

  final Set<String> _selectedTags = {};
  final List<String> _allTags = [
    '먹거리', '서울', '가족여행', '산책', '힐링', '카페',
    '아이들', '전주', '가평', '광명', '청주'
  ];


  bool get _isEditing => widget.post != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.post!.title;
      _contentController.text = widget.post!.content;
      _selectedCategory = widget.post!.category;
      _selectedTags.addAll(widget.post!.tags);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _savePost() async {
    if (_formKey.currentState!.validate()) {
      if (_isEditing) {
        await _boardService.updatePost(
          id: widget.post!.id,
          title: _titleController.text,
          content: _contentController.text,
          category: _selectedCategory,
          tags: _selectedTags.toList(),
        );
      } else {
        final newPost = Post(
          id: DateTime.now().millisecondsSinceEpoch,
          title: _titleController.text,
          content: _contentController.text,
          author: '새로운 작성자',
          views: 0,
          likes: 0,
          createdAt: DateTime.now().toIso8601String().substring(0, 10),
          category: _selectedCategory,
          tags: _selectedTags.toList(),
        );
        await _boardService.addPost(post: newPost);
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  Widget _buildTagChip(String tag) {
    final bool isSelected = _selectedTags.contains(tag);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedTags.remove(tag);
          } else {
            _selectedTags.add(tag);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
        decoration: isSelected
            ? BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20.0),
        )
            : BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: Colors.black, width: 1.0),
        ),
        child: Text(
          tag,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '게시글 수정' : '게시글 작성'),
        actions: [
          IconButton(
            onPressed: _savePost,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: () {
                  showMenu(
                    context: context,
                    position: const RelativeRect.fromLTRB(0, 56, 0, 0),
                    items: const [
                      PopupMenuItem(value: '자유 게시판', child: Text('자유 게시판')),
                      PopupMenuItem(value: '행사 게시판', child: Text('행사 게시판')),
                      PopupMenuItem(value: '팝업 게시판', child: Text('팝업 게시판')),
                    ],
                  ).then((value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedCategory,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '제목',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '제목을 입력해주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: '내용',
                  border: OutlineInputBorder(),
                ),
                maxLines: 10,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '내용을 입력해주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('태그 선택', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _allTags.map((tag) => _buildTagChip(tag)).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
