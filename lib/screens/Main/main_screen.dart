import 'package:fish_freshness_detection/screens/cook/recipe_screen.dart';
import 'package:fish_freshness_detection/screens/guide/guide_screen.dart';
import 'package:fish_freshness_detection/screens/scan/scan_screen.dart';
import 'package:flutter/material.dart';

import '../../widgets/bottom_bar.dart';
import '../history/history_screen.dart';
import '../home/home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    ScanScreen(),
    HistoryScreen(),
    GuideScreen(),
    RecipeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],

      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
