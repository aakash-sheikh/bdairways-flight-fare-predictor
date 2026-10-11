import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';
import '../widgets/intro_splash.dart';
import 'predictor_screen.dart';
import 'results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;
  bool _splashDone = false;

  final _screens = const [PredictorScreen(), ResultsScreen()];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 720;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Column(
            children: [
              _header(wide),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: Brand.maxWidth),
                    child: IndexedStack(index: _tabIndex, children: _screens),
                  ),
                ),
              ),
              if (!wide) _bottomNav(),
            ],
          ),
          if (!_splashDone)
            Positioned.fill(
              child: IntroSplash(
                onDone: () => setState(() => _splashDone = true),
              ),
            ),
        ],
      ),
    );
  }

  Widget _header(bool wide) {
    return Container(
      height: Brand.headerHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Brand.maxWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Brand.padX),
            child: Row(
              children: [
                // Hidden until the intro logo lands here.
                Opacity(
                  opacity: _splashDone ? 1 : 0,
                  child: const BrandLogo(size: Brand.logoSize),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          style: TextStyle(fontSize: 20, letterSpacing: 0.6),
                          children: [
                            TextSpan(
                              text: 'BD',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.navy,
                              ),
                            ),
                            TextSpan(
                              text: 'Airways',
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                                color: Color(0xFF1565B5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Flight Fare Study',
                        style: TextStyle(fontSize: 11, color: AppColors.grey),
                      ),
                    ],
                  ),
                ),
                if (wide) ...[
                  _tab(0, Icons.flight_takeoff, 'Fare Predictor'),
                  const SizedBox(width: 8),
                  _tab(1, Icons.bar_chart, 'Model Results'),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tab(int index, IconData icon, String label) {
    final selected = _tabIndex == index;
    return Material(
      color: selected ? AppColors.lightGrey : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => setState(() => _tabIndex = index),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 18,
                  color: selected ? AppColors.navy : AppColors.grey),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppColors.navy : AppColors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomNav() {
    return NavigationBar(
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
    );
  }
}
