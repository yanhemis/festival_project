import 'package:flutter/material.dart';
import 'package:flutterapp/models/post_model.dart';
import 'package:flutterapp/screens/board/board_detail_screen.dart';
import 'package:flutterapp/screens/board/board_write_screen.dart';
import 'package:flutterapp/services/board_service.dart';
import 'package:flutterapp/widgets/pagination_bar.dart';

class BoardListScreen extends StatefulWidget {
  const BoardListScreen({super.key});

  @override
  State<BoardListScreen> createState() => _BoardListScreenState();
}

class _BoardListScreenState extends State<BoardListScreen> {
  // 현재 페이지 및 페이지당 게시글 수
  int _currentPage = 1;
  final int _postsPerPage = 10;

  // 검색 상태 관련
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  // 로딩 상태
  bool _isLoading = true;

  // 게시글 데이터 및 필터링
  final BoardService _boardService = BoardService();
  List<Post> _allPosts = [];

  // 정렬 및 필터링 기준
  String _sortBy = 'createdAt';
  bool _isAscending = false;
  String _selectedCategory = '전체 게시판';

  // 다중 태그 선택
  final Set<String> _selectedTags = {'전체'};
  final List<String> _allTags = [
    '전체', '먹거리', '서울', '가족여행', '산책', '힐링', '카페',
    '아이들', '전주', '가평', '광명', '청주'
  ];

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    _searchController.addListener(() {
      _fetchPosts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPosts() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final fetchedPosts = await _boardService.fetchPosts(
        sortBy: _sortBy,
        isAscending: _isAscending,
        category: _selectedCategory,
        tags: _selectedTags,
        searchQuery: _searchController.text,
      );

      setState(() {
        _allPosts = fetchedPosts;
        _isLoading = false;
        if (_postsForCurrentPage.isEmpty && _currentPage > 1) {
          _currentPage--;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('게시글을 불러오는 데 실패했습니다.')),
      );
    }
  }

  List<Post> get _postsForCurrentPage {
    final startIndex = (_currentPage - 1) * _postsPerPage;
    final endIndex = startIndex + _postsPerPage;
    if (startIndex >= _allPosts.length) {
      return [];
    }
    return _allPosts.sublist(startIndex, endIndex > _allPosts.length ? _allPosts.length : endIndex);
  }

  int get _totalPages {
    if (_allPosts.isEmpty) return 1;
    return (_allPosts.length / _postsPerPage).ceil();
  }

  int get _startPageNumber {
    return ((_currentPage - 1) ~/ 5) * 5 + 1;
  }

  String _getSortByText() {
    switch (_sortBy) {
      case 'createdAt':
        return '최신순';
      case 'views':
        return '조회수순';
      case 'likes':
        return '추천순';
      default:
        return '최신순';
    }
  }

  // 태그
  Widget _buildTagChip(String tag) {
    final bool isSelected = _selectedTags.contains(tag);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (tag == '전체') {
            _selectedTags.clear();
            _selectedTags.add('전체');
          } else {
            _selectedTags.remove('전체');
            if (isSelected) {
              _selectedTags.remove(tag);
            } else {
              _selectedTags.add(tag);
            }
          }
          if (_selectedTags.isEmpty) {
            _selectedTags.add('전체');
          }
        });
        _fetchPosts();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
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
        title: _isSearching
            ? TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.black),
          decoration: const InputDecoration(
            hintText: '검색어를 입력하세요...',
            hintStyle: TextStyle(color: Colors.black54),
            border: InputBorder.none,
          ),
        )
        // 정렬
            : PopupMenuButton<String>(
          onSelected: (String newValue) {
            setState(() {
              _selectedCategory = newValue;
              _currentPage = 1;
            });
            _fetchPosts();
          },
          itemBuilder: (BuildContext context) => const [
            PopupMenuItem(value: '전체 게시판', child: Text('전체 게시판')),
            PopupMenuItem(value: '행사 게시판', child: Text('행사 게시판')),
            PopupMenuItem(value: '팝업 게시판', child: Text('팝업 게시판')),
            PopupMenuItem(value: '자유 게시판', child: Text('자유 게시판')),
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedCategory,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _fetchPosts();
                }
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.black, width: 1.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: const Text('태그 검색', style: TextStyle(color: Colors.black, fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _allTags.map((tag) => _buildTagChip(tag)).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 24,
                  width: 1,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.black, width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: PopupMenuButton<String>(
                    onSelected: (String newValue) {
                      setState(() {
                        if (_sortBy == newValue) {
                          _isAscending = !_isAscending;
                        } else {
                          _sortBy = newValue;
                          _isAscending = false;
                        }
                        _currentPage = 1;
                      });
                      _fetchPosts();
                    },
                    itemBuilder: (BuildContext context) => const [
                      PopupMenuItem(value: 'createdAt', child: Text('최신순')),
                      PopupMenuItem(value: 'views', child: Text('조회수순')),
                      PopupMenuItem(value: 'likes', child: Text('추천순')),
                    ],
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          Text(
                            _getSortByText(),
                            style: const TextStyle(color: Colors.black, fontSize: 12),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            _isAscending ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _allPosts.isEmpty
                ? const Center(child: Text('게시글이 없습니다.'))
                : ListView.builder(
              itemCount: _postsForCurrentPage.length,
              itemBuilder: (context, index) {
                final post = _postsForCurrentPage[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      '(${post.category}) ${post.title}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${post.author} • 조회수 ${post.views} • 추천수 ${post.likes}',
                          style: const TextStyle(fontSize: 12.0),
                        ),
                        Text(
                          post.createdAt,
                          style: const TextStyle(fontSize: 12.0),
                        ),
                      ],
                    ),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BoardDetailScreen(post: post),
                        ),
                      );
                      if (result == true) {
                        _fetchPosts();
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BoardWriteScreen(),
            ),
          );
          if (result == true) {
            _fetchPosts();
          }
        },
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: _allPosts.isEmpty
          ? null
          : PaginationBar(
        currentPage: _currentPage,
        totalPages: _totalPages,
        startPageNumber: _startPageNumber,
        onPageSelected: (pageNumber) {
          setState(() {
            _currentPage = pageNumber;
          });
        },
        onPreviousPressed: _startPageNumber > 1
            ? () {
          setState(() {
            _currentPage = _startPageNumber - 1;
          });
        }
            : null,
        onNextPressed: _startPageNumber + 4 < _totalPages
            ? () {
          setState(() {
            _currentPage = _startPageNumber + 5;
          });
        }
            : null,
      ),
    );
  }
}
