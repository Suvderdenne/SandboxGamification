import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/custom_drawer.dart';

class MainLayout extends StatefulWidget {
  final String title;
  final Widget body;
  final int currentNavIndex;
  final bool showBottomNav;
  final bool showDrawer;
  final bool showBackButton;
  final bool showLogout;
  final FloatingActionButton? floatingActionButton;

  const MainLayout({
    super.key,
    required this.title,
    required this.body,
    this.currentNavIndex = 0,
    this.showBottomNav = true,
    this.showDrawer = true,
    this.showBackButton = false,
    this.floatingActionButton,
    this.showLogout = false,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  void _onNavTap(int index) {
    // Bottom navigation дарахад холбогдох хуудас руу шилжүүлэх
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/topics');
        break;
      case 1:
        Navigator.pushNamed(context, '/leaderboard');
        break;
      case 2:
        Navigator.pushNamed(context, '/progress');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔴 HEADER
      appBar: CustomAppBar(
        title: widget.title,
        showBackButton: widget.showBackButton,
        showLogout: widget.showLogout,
      ),
      
      // 🔵 SIDEBAR (опционал)
      drawer: widget.showDrawer ? const CustomDrawer() : null,
      
      // 🟢 BODY (энд content орно)
      body: widget.body,
      
      // 🟡 FOOTER
      bottomNavigationBar: widget.showBottomNav
          ? CustomBottomNav(
              currentIndex: widget.currentNavIndex,
              onTap: _onNavTap,
            )
          : null,
      
      // 🟠 FLOATING ACTION BUTTON (опционал)
      floatingActionButton: widget.floatingActionButton,
    );
  }
}