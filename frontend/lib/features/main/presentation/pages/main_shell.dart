import 'package:flutter/material.dart';

import '../../../home/presentation/pages/home_page.dart';
import '../../../wallet/presentation/pages/wallet_page.dart';
import '../../../assets/presentation/pages/asset_page.dart';
import '../../../trading/presentation/pages/trading_page.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildCurrentPage(),
      bottomNavigationBar: MainBottomNavigationBar(
        currentIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return const HomePage();

      case 1:
        return const WalletPage();

      case 2:
        return const AssetPage();

      case 3:
        return const TradingPage();

      case 4:
        return const ProfilePage();

      default:
        return const HomePage();
    }
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
