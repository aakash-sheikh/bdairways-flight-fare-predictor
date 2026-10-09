import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'predictor_screen.dart';
import 'results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  final _screens = const [PredictorScreen(), ResultsScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('BDAirways Predictor',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Multi-Target ML Study',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.normal,
                    color: AppColors.grey)),
          ],
        ),
        toolbarHeight: 64,
      ),
      body: _screens[_tabIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.lightGrey,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.flight_takeoff_outlined),
            selectedIcon: Icon(Icons.flight_takeoff, color: AppColors.navy),
            label: 'Fare Predictor',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart, color: AppColors.navy),
            label: 'Model Results',
          ),
        ],
      ),
    );
  }
}
