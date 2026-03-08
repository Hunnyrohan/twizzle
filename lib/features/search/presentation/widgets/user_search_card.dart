import 'package:flutter/material.dart';
import 'package:twizzle/features/auth/domain/entities/user.dart';
import 'package:twizzle/core/utils/media_utils.dart';
import 'package:twizzle/widgets/custom_image.dart';
import 'package:twizzle/widgets/verified_badge.dart';

class UserSearchCard extends StatelessWidget {
  final User user;
  final bool isFollowing;
  final VoidCallback onFollowToggle;
  final bool isSelf;

  const UserSearchCard({
    Key? key,
    required this.user,
    required this.isFollowing,
    required this.onFollowToggle,
    this.isSelf = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget buildAvatarFallback(double size) {
      return Container(
        width: size,
        height: size,
        color: const Color(0xff1DA1F2),
        alignment: Alignment.center,
        child: Text(
          (user.name.isNotEmpty ? user.name : user.username)[0].toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      );
    }

    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/profile', arguments: user.username),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            ClipOval(
              child: user.image != null && user.image!.isNotEmpty
                  ? CustomImage(
                      imageUrl: MediaUtils.resolveImageUrl(user.image!),
                      width: 50,
                      height: 50,
                      errorWidget: buildAvatarFallback(50),
                    )
                  : buildAvatarFallback(50),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.name.isNotEmpty ? user.name : user.username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (user.isVerified) ...[
                        const SizedBox(width: 4),
                        const VerifiedBadge(size: 14),
                      ],
                    ],
                  ),
                  Text(
                    '@${user.username}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  if (user.bio != null && user.bio!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        user.bio!,
                        style: const TextStyle(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            if (!isSelf)
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: ElevatedButton(
                  onPressed: onFollowToggle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFollowing ? theme.cardColor : theme.colorScheme.onSurface,
                    foregroundColor: isFollowing ? theme.colorScheme.onSurface : theme.colorScheme.surface,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: isFollowing
                          ? BorderSide(color: theme.dividerColor, width: 1)
                          : BorderSide.none,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Text(
                    isFollowing ? 'Following' : 'Follow',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
