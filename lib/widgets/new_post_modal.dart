import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../data/api_exception.dart';
import '../data/posts_store.dart';
import '../widgets/user_avatar.dart';

// Cria post modal.
Future<bool?> showNewPostModal(BuildContext context) {
  return Navigator.of(context, rootNavigator: true).push<bool>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => const _NewPostScreen(),
    ),
  );
}

class _NewPostScreen extends StatefulWidget {
  const _NewPostScreen();

  @override
  State<_NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<_NewPostScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handlePublish() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    try {
      await PostsStore.instance.addPost(text);
      if (mounted) Navigator.of(context, rootNavigator: true).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.card,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500, fontSize: 15),
          ),
        ),
        leadingWidth: 100,
        title: const Text(
          'Nova postagem',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17, color: AppColors.textPrimary),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: _isSending ? null : _handlePublish,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cta,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              child: _isSending
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppColors.white)),
                    )
                  : const Text('Publicar', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAvatar(
              handle: PostsStore.currentUserHandle,
              radius: 21,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: TextField(
                controller: _controller,
                autofocus: true,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'O que está acontecendo?',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 17,
                  ),
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 17, height: 1.5, color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
