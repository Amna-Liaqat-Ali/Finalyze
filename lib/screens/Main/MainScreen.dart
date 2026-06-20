import 'package:Finalyze/screens/Main/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
