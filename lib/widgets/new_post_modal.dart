import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../data/posts_store.dart';
import '../data/profile_store.dart';

// Exibe o modal de criar postagem.
void showNewPostModal(BuildContext context) {
  final TextEditingController controller = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.inputBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  const Text(
                    'Nova postagem',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (controller.text.trim().isNotEmpty) {
                        PostsStore.instance.addPost(controller.text.trim());
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cta,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Publicar'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Builder(
                    builder: (context) {
                      final img = ProfileStore.instance.profileImageProvider;
                      return CircleAvatar(
                        radius: 21,
                        backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
                        backgroundImage: img,
                        child: img == null
                            ? Icon(Icons.person, color: AppColors.secondary.withValues(alpha: 0.5), size: 24)
                            : null,
                      );
                    },
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextField(
                      controller: controller,
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
                      style: const TextStyle(fontSize: 17, height: 1.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );
}
