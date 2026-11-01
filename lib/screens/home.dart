import 'package:flutter/material.dart';
import '../api.dart';
import 'home_content.dart';
import 'invest.dart';
import 'deposit.dart';
import 'withdraw.dart';
import 'history.dart';
import 'profile.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _pages = [
    const HomeContent(),
    const InvestScreen(),
    const DepositScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF064E3B),
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Akèy'),
          BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Envesti'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Depo'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Istwa'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Pwofil'),
        ],
      ),
    );
  }
}
