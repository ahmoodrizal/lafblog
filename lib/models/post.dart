import 'user.dart';

class Post {
  int? id;
  String? content;
  String? image;
  int? likesCount;
  int? commentsCount;
  User? user;
  bool? selfLiked;

  Post({
    this.id,
    this.content,
    this.image,
    this.likesCount,
    this.commentsCount,
    this.user,
    this.selfLiked,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      content: json['content'],
      image: json['image'],
      likesCount: json['likes_count'],
      commentsCount: json['comments_count'],
      selfLiked: json['likes'].length > 0,
      user: User(
        id: json['user']['id'],
        name: json['user']['name'],
        profile: json['user']['profile'],
      ),
    );
  }
}
