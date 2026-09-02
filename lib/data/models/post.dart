import '../../core/date_format.dart';

/// Representa uma postagem (ou resposta) retornada pela API Papacapim.

class Post {
  final int id;
  final int? postId;
  final String message;
  final DateTime? createdAt;
  final int likesNumber;
  final int repliesNumber;
  final bool youLiked;
  final PostAuthor user;

  Post({
    required this.id,
    required this.postId,
    required this.message,
    required this.createdAt,
    required this.likesNumber,
    required this.repliesNumber,
    required this.youLiked,
    required this.user,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      postId: json['post_id'] as int?,
      message: json['message'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      likesNumber: (json['likes_number'] as int?) ?? 0,
      repliesNumber: (json['replies_number'] as int?) ?? 0,
      youLiked: (json['you_liked'] as bool?) ?? false,
      user: PostAuthor.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  /// Converte para o Map<String, dynamic> que as telas e widgets da Parte 1
  /// (PostCard, PostDetailScreen, PostsStore etc.) já sabem exibir.
  Map<String, dynamic> toUiMap() {
    return {
      'id': id.toString(),
      'postId': postId?.toString(),
      'name': user.name,
      'handle': '@${user.login}',
      'profileImage': user.profileImage,
      'time': formatRelativeTime(createdAt),
      'content': message,
      'likes': likesNumber,
      'replies': repliesNumber,
      'liked': youLiked,
      // As respostas de um post específico são carregadas à parte, via GET /posts/{id}/replies (funcionalidade "Responder post", ainda não implementada). Por enquanto começa vazia.
      'replyList': <Map<String, dynamic>>[],
    };
  }
}

/// Versão simplificada de usuário que vem embutida dentro de cada post.
class PostAuthor {
  final String login;
  final String name;
  final String? profileImage;

  PostAuthor({required this.login, required this.name, this.profileImage});

  factory PostAuthor.fromJson(Map<String, dynamic> json) {
    return PostAuthor(
      login: json['login'] as String,
      name: json['name'] as String,
      profileImage: json['profile_image'] as String?,
    );
  }
}