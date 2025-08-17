class Post {
  final int id;
  final String title;
  final String content;
  final String author;
  final int views;
  final int likes;
  final String createdAt;
  final String category;
  final List<String> tags;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.views,
    required this.likes,
    required this.createdAt,
    required this.category,
    required this.tags,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      author: json['author'] as String,
      views: json['views'] as int,
      likes: json['likes'] as int,
      createdAt: json['createdAt'] as String,
      category: json['category'] as String,
      tags: List<String>.from(json['tags'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author': author,
      'views': views,
      'likes': likes,
      'createdAt': createdAt,
      'category': category,
      'tags': tags,
    };
  }
}
