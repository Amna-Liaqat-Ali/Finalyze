import 'package:Finalyze/screens/Main/bottom_nav.dart';
import 'package:flutter/material.dart';

import '../../constants/history_data.dart';
import '../../main.dart';
import '../cook/recipe_screen.dart';
import '../guide/guide_screen.dart';
import '../history/history_screen.dart';
import '../home/home_screen.dart';
import '../scan/scan_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = [
      const HomeScreen(),
      ScanScreen(cameras: cameras),
      HistoryScreen(historyItems: historyData),
      const GuideScreen(),
      const RecipeScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
