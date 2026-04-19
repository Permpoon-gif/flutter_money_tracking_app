// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_money_tracking_app/views/money_balance_ui.dart';
import 'package:flutter_money_tracking_app/views/money_in_ui.dart';
import 'package:flutter_money_tracking_app/views/money_out_ui.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1; // เริ่มที่หน้า Balance (กลาง)

  final List<Widget> _screens = [
    const MoneyIncomeScreen(),
    const MoneyBalanceScreen(),
    const MoneyOutcomeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF2DB89D),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.arrow_downward_rounded),
              label: 'รายรับ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'ภาพรวม',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.arrow_upward_rounded),
              label: 'รายจ่าย',
            ),
          ],
        ),
      ),
    );
  }
}
