import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../data/api_exception.dart';
import '../data/models/user.dart';
import '../data/repositories/users_repository.dart';
import '../widgets/user_avatar.dart';
import 'profile_screen.dart';

/// Tela que lista os seguidores de um usuário.
/// Chama GET /users/{login}/followers.
class FollowersScreen extends StatefulWidget {
  final String login;
  final String title;

  const FollowersScreen({
    super.key,
    required this.login,
    this.title = 'Seguidores',
  });

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  List<User> _followers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFollowers();
  }

  Future<void> _loadFollowers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final followers = await UsersRepository.instance.getFollowers(widget.login);
      if (!mounted) return;
      setState(() => _followers = followers);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.beige, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.cta),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, color: AppColors.textSecondary, size: 40),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _loadFollowers,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_followers.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.people_outline_rounded, color: AppColors.textSecondary, size: 48),
              SizedBox(height: 12),
              Text(
                'Nenhum seguidor encontrado.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFollowers,
      color: AppColors.cta,
      child: ListView.separated(
        itemCount: _followers.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: AppColors.inputBorder.withValues(alpha: 0.3),
        ),
        itemBuilder: (context, i) {
          final user = _followers[i];
          final handle = '@${user.login}';
          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                    name: user.name,
                    handle: handle,
                  ),
                ),
              );
            },
            leading: UserAvatar(
              imageUrl: user.profileImage,
              handle: handle,
              radius: 22,
            ),
            title: Text(
              user.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              handle,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          );
        },
      ),
    );
  }
}
