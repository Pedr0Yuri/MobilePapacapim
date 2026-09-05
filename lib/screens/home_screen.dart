import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'feed_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/app_drawer.dart';
import '../widgets/new_post_modal.dart';
import '../data/posts_store.dart';

// Tela principal que serve como "Casca" (Shell) para as outras abas.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ProfileScreenState> _profileKey = GlobalKey<ProfileScreenState>();
  final GlobalKey<FeedScreenState> _feedKey = GlobalKey<FeedScreenState>();
  final GlobalKey<SearchScreenState> _searchKey = GlobalKey<SearchScreenState>();

  late final List<Widget> _pages = [
    FeedScreen(key: _feedKey),
    SearchScreen(key: _searchKey),
    ProfileScreen(key: _profileKey),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: AppDrawer(
        onLogout: () {
          Navigator.of(context).pop();
          Navigator.pushReplacementNamed(context, '/login');
        },
        onProfileTap: () {
          Navigator.of(context).pop();
          _profileKey.currentState?.refreshAll();
          setState(() => _currentIndex = 2);
        },
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showNewPostModal(context);
          if (result == true) {
            if (_currentIndex == 0) {
              PostsStore.instance.loadFeed();
            } else if (_currentIndex == 2) {
              _profileKey.currentState?.refreshAll();
            }
          }
        },
        backgroundColor: AppColors.cta,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: AppColors.white, size: 30),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 0) {
            if (_currentIndex == 0) {
              _feedKey.currentState?.scrollToTop();
            } else {
              PostsStore.instance.loadFeed();
            }
          } else if (index == 1) {
            if (_currentIndex == 1) {
              _searchKey.currentState?.scrollToTop();
            }
          } else if (index == 2) {
            if (_currentIndex == 2) {
              _profileKey.currentState?.scrollToTop();
            } else {
              _profileKey.currentState?.refreshAll();
            }
          }
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
