import 'package:flutter/material.dart';
import 'package:manager_app/core/theme/app_colors.dart';

class MainShell extends StatefulWidget {
  final int currentIndex;
  final Widget child;
  final ValueChanged<int> onTabChanged;

  const MainShell({
    super.key,
    required this.currentIndex,
    required this.child,
    required this.onTabChanged,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? AppColors.surfaceDark : Colors.white;
    final unselectedColor = isDark ? Colors.white30 : Colors.grey.shade400;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  label: 'Dashboard',
                  isSelected: widget.currentIndex == 0,
                  unselectedColor: unselectedColor,
                  onTap: () => widget.onTabChanged(0),
                ),
                _NavItem(
                  icon: Icons.restaurant_menu_outlined,
                  activeIcon: Icons.restaurant_menu,
                  label: 'Menu',
                  isSelected: widget.currentIndex == 1,
                  unselectedColor: unselectedColor,
                  onTap: () => widget.onTabChanged(1),
                ),
                _NavItem(
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long,
                  label: 'Orders',
                  isSelected: widget.currentIndex == 2,
                  unselectedColor: unselectedColor,
                  onTap: () => widget.onTabChanged(2),
                ),
                _NavItem(
                  icon: Icons.schedule_outlined,
                  activeIcon: Icons.schedule,
                  label: 'Slots',
                  isSelected: widget.currentIndex == 3,
                  unselectedColor: unselectedColor,
                  onTap: () => widget.onTabChanged(3),
                ),
                _NavItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Profile',
                  isSelected: widget.currentIndex == 4,
                  unselectedColor: unselectedColor,
                  onTap: () => widget.onTabChanged(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final Color unselectedColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.unselectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 22,
              color: isSelected ? primaryColor : unselectedColor,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? primaryColor : unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
