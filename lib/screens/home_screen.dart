import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'feed_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/app_drawer.dart';
import '../widgets/new_post_modal.dart';

// Tela principal que serve como "Casca" (Shell) para as outras abas.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _pages = const [
    FeedScreen(),
    SearchScreen(),
    ProfileScreen(),
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
        onPressed: () => showNewPostModal(context),
        backgroundColor: AppColors.cta,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: AppColors.white, size: 30),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
