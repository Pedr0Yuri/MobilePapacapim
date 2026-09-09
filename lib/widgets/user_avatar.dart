import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../data/posts_store.dart';
import '../data/profile_store.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? handle;
  final double radius;
  final double? iconSize;

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.handle,
    this.radius = 21,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = handle != null && handle == PostsStore.currentUserHandle;
    final effectiveIconSize = iconSize ?? (radius * 1.15);

    if (isMe) {
      final localBytes = ProfileStore.instance.localProfileImageBytes;
      if (localBytes != null) {
        return ClipOval(
          child: SizedBox(
            width: radius * 2,
            height: radius * 2,
            child: Image.memory(
              localBytes,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildFallback(effectiveIconSize),
            ),
          ),
        );
      }

      final networkUrl = ProfileStore.instance.networkProfileImageUrl;
      if (networkUrl != null && networkUrl.isNotEmpty) {
        return _buildNetworkAvatar(networkUrl, effectiveIconSize);
      }
    }

    final url = imageUrl;
    if (url != null && url.isNotEmpty) {
      return _buildNetworkAvatar(url, effectiveIconSize);
    }

    return _buildFallback(effectiveIconSize);
  }

  Widget _buildNetworkAvatar(String url, double fallbackIconSize) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: NetworkImage(url),
      onBackgroundImageError: (exception, stackTrace) {
        print('ERRO AO CARREGAR FOTO: $exception');
        print('URL DA FOTO: $url');
      },
    );
  }

  Widget _buildFallback(double size) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.secondary.withValues(alpha: 0.15),
      ),
      child: Icon(
        Icons.person,
        color: AppColors.secondary.withValues(alpha: 0.5),
        size: size,
      ),
    );
  }
}
