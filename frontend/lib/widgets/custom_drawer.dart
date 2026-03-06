// widgets/custom_drawer.dart

import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/api_service.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── Header
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
                  child:
                      Icon(Icons.person, size: 40, color: AppColors.primary),
                ),
                const SizedBox(height: AppSpacing.sm),
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

          // ── Main navigation
          _NavTile(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            title: 'Нүүр хуудас',
            isActive: currentRoute == '/topics',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/topics');
            },
          ),
          _NavTile(
            icon: Icons.emoji_events_outlined,
            activeIcon: Icons.emoji_events,
            title: 'Тэргүүлэгчид',
            isActive: currentRoute == '/leaderboard',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/leaderboard');
            },
          ),
          _NavTile(
            icon: Icons.school_outlined,
            activeIcon: Icons.school,
            title: 'Миний явц',
            isActive: currentRoute == '/progress',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/progress');
            },
          ),
          _NavTile(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            title: 'Профайл',
            isActive: currentRoute == '/profile',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),

          // ── Admin section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'УДИРДЛАГА',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
          ),

          // Admin card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/admin');
                },
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(children: [
                      const Icon(Icons.admin_panel_settings,
                          color: Colors.white, size: 22),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Админ самбар',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            Text('Бүрэн удирдлага',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          color: Colors.white70, size: 14),
                    ]),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Teacher card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/teacher');
                },
                child: Ink(
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.secondary.withOpacity(0.3)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(children: [
                      const Icon(Icons.assignment_ind,
                          color: AppColors.secondary, size: 22),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Багшийн самбар',
                                style: TextStyle(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            Text('Хичээл, тест удирдах',
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          color: AppColors.textSecondary, size: 14),
                    ]),
                  ),
                ),
              ),
            ),
          ),

          // ── Footer
          const Divider(height: 32, indent: 16, endIndent: 16),

          _NavTile(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            title: 'Тохиргоо',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),

          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('Гарах',
                style: TextStyle(
                    color: AppColors.error, fontWeight: FontWeight.w600)),
            onTap: () async {
              await ApiService.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false);
              }
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Reusable nav tile with active highlight
class _NavTile extends StatelessWidget {
  final IconData icon;
  final IconData? activeIcon;
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    this.activeIcon,
    required this.title,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        isActive ? (activeIcon ?? icon) : icon,
        color: isActive ? AppColors.primary : AppColors.textSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      tileColor: isActive ? AppColors.primary.withOpacity(0.08) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      onTap: onTap,
    );
  }
}