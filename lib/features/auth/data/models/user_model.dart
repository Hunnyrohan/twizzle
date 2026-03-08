import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.name,
    required super.username,
    required super.email,
    required super.password,
    required super.token,
    super.image,
    super.bio,
    super.location,
    super.website,
    super.coverImage,
    super.joinedAt,
    super.isFollowing = false,
    super.isSelf = false,
    super.followersCount = 0,
    super.followingCount = 0,
    super.isVerified = false,
    super.verifiedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, [String password = '']) {
    // Backend returns { token: "...", user: { ... } } sometimes, handle both
    final userData = json.containsKey('user') ? json['user'] as Map<String, dynamic> : json;
    final token = json['token'] as String? ?? userData['token'] as String? ?? '';

    return UserModel(
      id: (userData['_id'] ?? userData['id'] ?? '').toString(),
      name: userData['name'] as String? ?? userData['displayName'] as String? ?? '',
      username: userData['username'] as String? ?? '',
      email: userData['email'] as String? ?? '',
      password: password,
      token: token,
      image: userData['image'] as String? ?? 
             userData['avatar'] as String? ?? 
             userData['avatarUrl'] as String?,
      bio: userData['bio'] as String?,
      location: userData['location'] as String?,
      website: userData['website'] as String?,
      coverImage: userData['coverImage'] as String? ?? 
                  userData['cover'] as String?,
      joinedAt: userData['createdAt'] != null ? DateTime.parse(userData['createdAt'] as String) : null,
      isFollowing: userData['isFollowing'] as bool? ?? false,
      isSelf: userData['isSelf'] as bool? ?? false,
      followersCount: userData['followersCount'] as int? ?? 0,
      followingCount: userData['followingCount'] as int? ?? 0,
      isVerified: userData['isVerified'] as bool? ?? false,
      verifiedAt: userData['verifiedAt'] != null 
          ? DateTime.parse(userData['verifiedAt'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'token': token,
      'image': image,
      'bio': bio,
      'location': location,
      'website': website,
      'coverImage': coverImage,
      'isFollowing': isFollowing,
      'isSelf': isSelf,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'isVerified': isVerified,
      'verifiedAt': verifiedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? username,
    String? email,
    String? password,
    String? token,
    String? image,
    String? bio,
    String? location,
    String? website,
    String? coverImage,
    DateTime? joinedAt,
    bool? isFollowing,
    bool? isSelf,
    int? followersCount,
    int? followingCount,
    bool? isVerified,
    DateTime? verifiedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      token: token ?? this.token,
      image: image ?? this.image,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      website: website ?? this.website,
      coverImage: coverImage ?? this.coverImage,
      joinedAt: joinedAt ?? this.joinedAt,
      isFollowing: isFollowing ?? this.isFollowing,
      isSelf: isSelf ?? this.isSelf,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      isVerified: isVerified ?? this.isVerified,
      verifiedAt: verifiedAt ?? this.verifiedAt,
    );
  }
}
