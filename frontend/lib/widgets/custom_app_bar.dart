// widgets/custom_app_bar.dart

import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/api_service.dart';
import '../services/theme_service.dart';
import 'theme_switch.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool showLogout;
  final bool showAdmin;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = false,
    this.showLogout = true,
    this.showAdmin = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: showBackButton,
      actions: [
        ValueListenableBuilder<ThemeMode>(
          valueListenable: ThemeService.themeMode,
          builder: (context, mode, child) {
            return ThemeSwitch(
              themeMode: mode,
              onThemeChanged: ThemeService.setThemeMode,
            );
          },
        ),
        if (actions != null) ...actions!,
        if (showAdmin)
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_outlined),
            tooltip: 'Админ самбар',
            onPressed: () => Navigator.pushNamed(context, '/admin'),
          ),
        if (showLogout)
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Гарах',
            onPressed: () => _showLogoutDialog(context),
          ),
      ],
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Гарах'),
        content: const Text('Үнэхээр гарахыг хүсэж байна уу?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Болих'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Гарах'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ApiService.logout();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}