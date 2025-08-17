import 'package:flutterapp/models/post_model.dart';
import 'package:flutterapp/services/dummy_posts.dart';
import 'dart:async';

class BoardService {
  /// 게시글 데이터를 가져오는 메서드 (정렬, 필터링, 검색 포함)
  Future<List<Post>> fetchPosts({
    String? category,
    String? sortBy,
    bool? isAscending,
    Set<String>? tags,
    String? searchQuery,
  }) async {
    // API 호출 지연 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 500));

    // 더미 데이터를 복사하여 필터링 및 정렬에 사용
    List<Post> filteredPosts = List<Post>.from(dummyPosts);

    // 1. 카테고리 필터링
    if (category != null && category != '전체 게시판') {
      filteredPosts = filteredPosts.where((post) => post.category == category).toList();
    }

    // 2. 태그 필터링
    if (tags != null && tags.isNotEmpty && !tags.contains('전체')) {
      filteredPosts = filteredPosts.where((post) {
        return tags.every((tag) => post.tags.contains(tag));
      }).toList();
    }

    // 3. 검색어 필터링
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filteredPosts = filteredPosts.where((post) {
        return post.title.toLowerCase().contains(query) ||
            post.content.toLowerCase().contains(query) ||
            post.author.toLowerCase().contains(query);
      }).toList();
    }

    // 4. 정렬 로직
    if (sortBy != null) {
      filteredPosts.sort((a, b) {
        Comparable aValue;
        Comparable bValue;

        if (sortBy == 'createdAt') {
          aValue = a.createdAt;
          bValue = b.createdAt;
        } else if (sortBy == 'views') {
          aValue = a.views;
          bValue = b.views;
        } else if (sortBy == 'likes') {
          aValue = a.likes;
          bValue = b.likes;
        } else {
          aValue = a.createdAt;
          bValue = b.createdAt;
        }

        final result = aValue.compareTo(bValue);
        return (isAscending ?? false) ? result : -result;
      });
    }

    return filteredPosts;
  }

  /// 게시글 조회수를 증가시키는 메서드
  Future<Post> incrementViews({required int id}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = dummyPosts.indexWhere((post) => post.id == id);
    if (index != -1) {
      final oldPost = dummyPosts[index];
      dummyPosts[index] = Post(
        id: oldPost.id,
        title: oldPost.title,
        content: oldPost.content,
        author: oldPost.author,
        views: oldPost.views + 1,
        likes: oldPost.likes,
        createdAt: oldPost.createdAt,
        category: oldPost.category,
        tags: oldPost.tags,
      );
      return dummyPosts[index];
    }
    throw Exception('게시글을 찾을 수 없습니다.');
  }

  /// 게시글 추천수를 증가시키는 메서드
  Future<Post> incrementLikes({required int id}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = dummyPosts.indexWhere((post) => post.id == id);
    if (index != -1) {
      final oldPost = dummyPosts[index];
      dummyPosts[index] = Post(
        id: oldPost.id,
        title: oldPost.title,
        content: oldPost.content,
        author: oldPost.author,
        views: oldPost.views,
        likes: oldPost.likes + 1,
        createdAt: oldPost.createdAt,
        category: oldPost.category,
        tags: oldPost.tags,
      );
      return dummyPosts[index];
    }
    throw Exception('게시글을 찾을 수 없습니다.');
  }

  /// 게시글을 추가하는 메서드
  Future<Post> addPost({required Post post}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newId = dummyPosts.isNotEmpty ? dummyPosts.first.id + 1 : 1;
    final newPost = Post(
      id: newId,
      title: post.title,
      content: post.content,
      author: post.author,
      views: 0,
      likes: 0,
      createdAt: DateTime.now().toIso8601String().substring(0, 10),
      category: post.category,
      tags: post.tags,
    );
    dummyPosts.insert(0, newPost);
    return newPost;
  }

  /// 게시글을 수정하는 메서드
  Future<void> updatePost({
    required int id,
    required String title,
    required String content,
    required String category,
    required List<String> tags,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = dummyPosts.indexWhere((post) => post.id == id);
    if (index != -1) {
      final oldPost = dummyPosts[index];
      dummyPosts[index] = Post(
        id: id,
        title: title,
        content: content,
        author: oldPost.author,
        views: oldPost.views,
        likes: oldPost.likes,
        createdAt: oldPost.createdAt,
        category: category,
        tags: tags,
      );
    }
  }

  /// 게시글을 삭제하는 메서드
  Future<void> deletePost({required int id}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    dummyPosts.removeWhere((post) => post.id == id);
  }
}
