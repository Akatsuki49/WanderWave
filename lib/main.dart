// lib/main.dart

import 'package:flutter/material.dart';
import 'screens/profile_screen.dart';
import 'screens/itinerary_screen.dart';
import 'screens/diary_screen.dart';
import 'screens/expenses_screen.dart';
import './widgets/bottom_bar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    ProfileScreen(),
    ItineraryScreen(),
    DiaryScreen(),
    ExpensesScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Travel App'),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar:
          BottomNavigationBarWidget(_selectedIndex, _onItemTapped),
    );
  }
}
