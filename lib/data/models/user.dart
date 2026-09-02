/// Representa um usuário retornado pela API Papacapim.

class User {
  final String login;
  final String name;
  final String? profileImage;
  final int? followersNumber;
  final int? followingNumber;
  final bool? youFollow;
  final bool? followsYou;
  final DateTime? createdAt;

  User({
    required this.login,
    required this.name,
    this.profileImage,
    this.followersNumber,
    this.followingNumber,
    this.youFollow,
    this.followsYou,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      login: json['login'] as String,
      name: json['name'] as String,
      profileImage: json['profile_image'] as String?,
      followersNumber: json['followers_number'] as int?,
      followingNumber: json['following_number'] as int?,
      youFollow: json['you_follow'] as bool?,
      followsYou: json['follows_you'] as bool?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}
