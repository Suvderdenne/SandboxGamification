import 'package:flutter/material.dart';
import '../layouts/main_layout.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../models/user.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfile? _profile;
  bool _loading = true;
  
  // Stats (дараа нь testApp-с татна)
  int _totalQuizzes = 0;
  int _completedQuizzes = 0;
  double _averageScore = 0.0;
  // int _totalPoints = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadStats();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await ApiService.getProfile();
      if (data != null && mounted) {
        setState(() {
          _profile = UserProfile.fromJson(data);
          _loading = false;
        });
      }
    } catch (e) {
      print("❌ Profile load error: $e");
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loadStats() async {
    try {
      // Хийх зүйл: : testApp-с статистик татах API дуудах
      // Одоогоор хардкод өгөгдөл
      setState(() {
        _totalQuizzes = 15;
        _completedQuizzes = 8;
        _averageScore = 78.5;
        // _totalPoints = 1250;
      });
    } catch (e) {
      print("❌ Stats load error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Профайл',
      currentNavIndex: 3,  // Profile tab
      showBottomNav: true,
      showDrawer: true,
      showBackButton: false,
      showLogout: true,
      
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _profile == null
              ? const Center(child: Text('Профайл ачааллахад алдаа гарлаа'))
              : RefreshIndicator(
                  onRefresh: _loadProfile,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        _buildProfileHeader(),
                        const SizedBox(height: AppSpacing.lg),
                        _buildStatsCards(),
                        const SizedBox(height: AppSpacing.lg),
                        _buildAchievementsSection(),
                        const SizedBox(height: AppSpacing.lg),
                        _buildSettingsSection(),
                      ],
                    ),
                  ),
                ),
    );
  }

  // 👤 Profile header with avatar
  Widget _buildProfileHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    _profile!.username[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Username
            Text(
              _profile!.username,
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: AppSpacing.xs),
            
            // Email
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.email, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  _profile!.email,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Edit button
            OutlinedButton.icon(
              onPressed: () {
                // Хийх зүйл: : Edit profile page руу шилжих
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Засах хуудас удахгүй нэмэгдэнэ')),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Засах'),
            ),
          ],
        ),
      ),
    );
  }

  // 📊 Stats cards
  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.quiz,
            title: 'Нийт тест',
            value: '$_completedQuizzes / $_totalQuizzes',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatCard(
            icon: Icons.star,
            title: 'Дундаж оноо',
            value: '${_averageScore.toStringAsFixed(1)}%',
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }

  // 🏆 Achievements section
  Widget _buildAchievementsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Амжилтууд',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // : Achievements page
                  },
                  child: const Text('Бүгдийг харах'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Achievement badges
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                _AchievementBadge(
                  icon: Icons.emoji_events,
                  title: 'Анхны тест',
                  color: AppColors.warning,
                  unlocked: true,
                ),
                _AchievementBadge(
                  icon: Icons.local_fire_department,
                  title: '5 хоног streak',
                  color: AppColors.error,
                  unlocked: true,
                ),
                _AchievementBadge(
                  icon: Icons.workspace_premium,
                  title: '90%+ оноо',
                  color: AppColors.primary,
                  unlocked: false,
                ),
                _AchievementBadge(
                  icon: Icons.military_tech,
                  title: '50 тест',
                  color: AppColors.success,
                  unlocked: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ⚙️ Settings section
  Widget _buildSettingsSection() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Мэдэгдэл'),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // Хийх зүйл: : Toggle notifications
              },
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Хэл'),
            subtitle: const Text('Монгол'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Хийх зүйл: : Language selector
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Харанхуй горим'),
            trailing: Switch(
              value: false,
              onChanged: (value) {
                // Хийх зүйл: : Toggle dark mode
              },
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Тусламж'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Хийх зүйл: : Help page
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Апп-н тухай'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showAboutDialog();
            },
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Sandbox Quiz',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.school, size: 36, color: Colors.white),
      ),
      children: [
        const Text('Gamification ашигласан сургалтын платформ'),
        const SizedBox(height: 8),
        const Text('© 2024 Sandbox Club'),
      ],
    );
  }
}

// 📊 Stat card widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              title,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// 🏆 Achievement badge widget
class _AchievementBadge extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final bool unlocked;

  const _AchievementBadge({
    required this.icon,
    required this.title,
    required this.color,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: unlocked ? color.withOpacity(0.1) : Colors.grey[200],
            shape: BoxShape.circle,
            border: Border.all(
              color: unlocked ? color : Colors.grey[400]!,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: unlocked ? color : Colors.grey[400],
            size: 28,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: unlocked ? AppColors.textPrimary : Colors.grey[600],
            fontWeight: unlocked ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}