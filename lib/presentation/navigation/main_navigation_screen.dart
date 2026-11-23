import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../state/impact_provider.dart';
import '../../state/pantry_provider.dart';
import '../../state/subscription_provider.dart';
import '../screens/expiry/expiry_center_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/impact/impact_screen.dart';
import '../screens/pantry/pantry_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/subscription/subscription_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onSelectTab(int index) {
    setState(() => _currentIndex = index);
    if (index == 3) {
      context.read<ImpactProvider>().loadActivities();
    } else {
      context.read<PantryProvider>().loadItems();
    }
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subscription = context.watch<SubscriptionProvider>();

    // If subscription is required and access has expired, present paywall
    if (!subscription.hasActiveAccess) {
      return const SubscriptionScreen(isPaywallModal: true);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    final screens = [
      HomeScreen(
        onNavigateToTab: _onSelectTab,
        onOpenSettings: _openSettings,
      ),
      PantryScreen(onOpenSettings: _openSettings),
      ExpiryCenterScreen(onOpenSettings: _openSettings),
      ImpactScreen(onOpenSettings: _openSettings),
    ];

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final nav = Navigator.of(context);
        if (nav.canPop()) {
          nav.pop();
          return;
        }
        if (_currentIndex != 0) {
          _onSelectTab(0);
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.canvas,
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
        bottomNavigationBar: _buildBottomNav(isDark, l10n),
      ),
    );
  }

  Widget _buildBottomNav(bool isDark, AppLocalizations? l10n) {
    final bgColor = isDark ? AppColors.darkSurface : AppColors.canvas;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final unselectedColor = isDark ? AppColors.textSecondaryDark : AppColors.softGray;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(color: borderColor, width: 1.0),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A292D29),
            offset: Offset(0, -2),
            blurRadius: 12,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                label: l10n?.homeTitle ?? 'Início',
                icon: Icons.cottage_outlined,
                activeIcon: Icons.cottage,
                unselectedColor: unselectedColor,
              ),
              _buildNavItem(
                index: 1,
                label: l10n?.pantryTitle ?? 'Despensa',
                icon: Icons.kitchen_outlined,
                activeIcon: Icons.kitchen,
                unselectedColor: unselectedColor,
              ),
              _buildNavItem(
                index: 2,
                label: l10n?.expiryCenterTitle ?? 'Validades',
                icon: Icons.schedule_outlined,
                activeIcon: Icons.schedule,
                unselectedColor: unselectedColor,
              ),
              _buildNavItem(
                index: 3,
                label: l10n?.impactTitle ?? 'Meu impacto',
                icon: Icons.eco_outlined,
                activeIcon: Icons.eco,
                unselectedColor: unselectedColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
    required Color unselectedColor,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppColors.forestGreen : unselectedColor;

    return Expanded(
      child: InkWell(
        onTap: () => _onSelectTab(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 22,
              color: color,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
