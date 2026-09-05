import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../data/posts_store.dart';
import '../data/profile_store.dart';
import '../core/api_config.dart';

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
    final absoluteUrl = ApiConfig.getProfileImageUrl(url);

    return ClipOval(
      child: SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: Image.network(
          absoluteUrl,
          fit: BoxFit.cover,
          width: radius * 2,
          height: radius * 2,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: SizedBox(
                width: radius * 0.8,
                height: radius * 0.8,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: AppColors.secondary.withValues(alpha: 0.4),
                ),
              ),
            );
          },
          errorBuilder: (_, __, ___) => _buildFallback(fallbackIconSize),
        ),
      ),
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
