import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/api_service.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: AppColors.primary),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Хэрэглэгч ${ApiService.userId ?? ""}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Нүүр хуудас'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/topics');
            },
          ),
          ListTile(
            leading: const Icon(Icons.emoji_events),
            title: const Text('Тэргүүлэгчид'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/leaderboard');
            },
          ),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Миний явц'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/progress');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Профайл'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings, color: AppColors.primary),
            title: const Text('Админ самбар'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/admin');
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment_ind, color: AppColors.secondary),
            title: const Text('Багшийн самбар'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/teacher');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Тохиргоо'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('Гарах', style: TextStyle(color: AppColors.error)),
            onTap: () async {
              await ApiService.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              }
            },
          ),
        ],
      ),
    );
  }
}