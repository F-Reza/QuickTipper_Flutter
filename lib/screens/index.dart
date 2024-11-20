
import 'package:flutter/material.dart';
import 'history.dart';
import 'split.dart';
import 'tips.dart';

class IndexScreen extends StatefulWidget {
  const IndexScreen({super.key});

  @override
  State<IndexScreen> createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const TipsScreen(),
    const SplitBillScreen(),
    const HistoryScreen(),
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
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.tips_and_updates_outlined),
            SizedBox(width: 5,),
            Text("QuickTipper",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),

        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFFF15B25),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFF15B25),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        elevation: 8.0,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.calculate,
              size: 30,
              color: _selectedIndex == 0 ? const Color(0xFFF15B25) : Colors.grey,
            ),
            label: 'Tips',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.splitscreen,
              size: 30,
              color: _selectedIndex == 1 ? const Color(0xFFF15B25) : Colors.grey,
            ),
            label: 'Split Bill',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.history,
              size: 30,
              color: _selectedIndex == 2 ? const Color(0xFFF15B25) : Colors.grey,
            ),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
