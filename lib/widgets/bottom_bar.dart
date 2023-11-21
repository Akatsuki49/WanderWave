// lib/widgets/bottom_navigation_bar.dart

import 'package:flutter/material.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavigationBarWidget(this.selectedIndex, this.onItemTapped,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      selectedItemColor: const Color(0xFF0074B7), // Blue color
      unselectedItemColor: Colors.grey,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Itinerary',
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Diary',
            backgroundColor: Colors.black),
        BottomNavigationBarItem(
          icon: Icon(Icons.attach_money),
          label: 'Expenses',
        ),
      ],
      currentIndex: selectedIndex,
      onTap: onItemTapped,
    );
  }
}
