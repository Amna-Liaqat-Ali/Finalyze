import 'package:Finalyze/screens/Main/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import '../chat/ai_chat_sheet.dart';
import '../cook/recipe_screen.dart';
import '../guide/guide_screen.dart';
import '../history/history_screen.dart';
import '../home/home_screen.dart';
import '../premium/premium_screen.dart';
import '../scan/scan_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final GlobalKey<HistoryScreenState> _historyKey = GlobalKey();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = [
      const HomeScreen(),
      ScanScreen(
        cameras: cameras,
        onScanCompleted: () => _historyKey.currentState?.refreshHistory(),
      ),
      HistoryScreen(key: _historyKey, userId: ''),
      const GuideScreen(),
      const RecipeScreen(),
    ];

    // Show premium sheet once per install after the first frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowPremium());
  }

  Future<void> _maybeShowPremium() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('premium_seen') ?? false;
    if (seen) return;
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (_) => const PremiumSheet(),
    );
    await prefs.setBool('premium_seen', true);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 2) {
      _historyKey.currentState?.refreshHistory();
    }
  }

  void _openChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      useSafeArea: true,
      builder: (_) => const AiChatSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      floatingActionButton: _buildChatFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildChatFab() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 72),
      child: GestureDetector(
        onTap: _openChat,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0D2E5C), Color(0xFF1A5694), Color(0xFF0891B2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0891B2).withOpacity(0.40),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.chat_bubble_rounded,
              color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
