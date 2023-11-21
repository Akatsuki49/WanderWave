import 'package:flutter/material.dart';
import 'package:wanderwave/screens/Diary/diary_screen.dart';
import 'package:wanderwave/screens/expenses_screen.dart';
import 'package:wanderwave/screens/itinerary_screen.dart';
import 'package:wanderwave/screens/profile_screen.dart';
import 'package:wanderwave/widgets/bottom_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ProfileScreen(),
    const ItineraryScreen(),
    const TravelDiaryScreen(),
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
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text('Travel App'),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar:
          BottomNavigationBarWidget(_selectedIndex, _onItemTapped),
    );
  }
}
