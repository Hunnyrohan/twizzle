import 'package:equatable/equatable.dart';

// lib/features/auth/domain/entities/user.dart
class User extends Equatable {
  final String id;
  final String name;
  final String username;
  final String email;
  final String password;
  final String token;
  final String? image;
  final String? bio;
  final String? location;
  final String? website;
  final String? coverImage;
  final DateTime? joinedAt;
  final bool isFollowing;
  final bool isSelf;
  final int followersCount;
  final int followingCount;
  final bool isVerified;
  final DateTime? verifiedAt;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.password,
    required this.token,
    this.image,
    this.bio,
    this.location,
    this.website,
    this.coverImage,
    this.joinedAt,
    this.isFollowing = false,
    this.isSelf = false,
    this.followersCount = 0,
    this.followingCount = 0,
    this.isVerified = false,
    this.verifiedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        username,
        email,
        password,
        token,
        image,
        bio,
        location,
        website,
        coverImage,
        joinedAt,
        isFollowing,
        isSelf,
        followersCount,
        followingCount,
        isVerified,
        verifiedAt,
      ];
}