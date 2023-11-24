import 'package:flutter/material.dart';
import 'package:wanderwave/Itinerary/itinerary_page.dart';
import 'package:wanderwave/screens/Diary/diary_screen.dart';
import 'package:wanderwave/screens/expenses/expenses_screen.dart';
import 'package:wanderwave/screens/profile/profile_screen.dart';
import 'package:wanderwave/widgets/bottom_bar.dart';
import 'package:wanderwave/Itinerary/itinerary_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ProfileScreen(),
    const ItineraryList(),
    const TravelDiaryScreen(),
    const ExpensesScreen(),
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
