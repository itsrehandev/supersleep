import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.child});

  final Widget child;

  static const _navItems = <_NavItem>[
    _NavItem(
      route: '/alarms',
      label: 'Alarms',
      icon: Icons.alarm_outlined,
      selectedIcon: Icons.alarm,
    ),
    _NavItem(
      route: '/streak',
      label: 'Streak',
      icon: Icons.local_fire_department_outlined,
      selectedIcon: Icons.local_fire_department,
    ),
    _NavItem(
      route: '/timer',
      label: 'Timer',
      icon: Icons.hourglass_empty_rounded,
      selectedIcon: Icons.hourglass_full_rounded,
    ),
    _NavItem(
      route: '/stopwatch',
      label: 'Stopwatch',
      icon: Icons.timer_outlined,
      selectedIcon: Icons.timer,
    ),
    _NavItem(
      route: '/settings',
      label: 'Settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
    ),
  ];

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _navItems.length; i++) {
      if (location == _navItems[i].route ||
          (location.startsWith(_navItems[i].route) &&
              _navItems[i].route != '/')) {
        return i;
      }
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    if (index >= 0 && index < _navItems.length) {
      context.go(_navItems[index].route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: _navItems.map((item) {
          return NavigationDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.selectedIcon),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.route,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String route;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
