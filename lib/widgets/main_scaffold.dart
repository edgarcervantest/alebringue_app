// lib/widgets/main_scaffold.dart
import 'package:flutter/material.dart';
import 'package:alebringue/widgets/appbar.dart';
import 'package:alebringue/widgets/bottom_navbar.dart';

class MainScaffold extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final Function(int) onNavTap;
  final String title;
  final List<Widget>? appBarActions;
  final bool showAppBarLeading;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLogoutTap;

  const MainScaffold({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.onNavTap,
    required this.title,
    this.appBarActions,
    this.showAppBarLeading = true,
    this.onProfileTap,
    this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: title,
        actions: appBarActions,
        showLeading: showAppBarLeading,
        onProfileTap: onProfileTap,
        onLogoutTap: onLogoutTap,
      ),
      body: body,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentIndex,
        onTap: onNavTap,
      ),
    );
  }
}