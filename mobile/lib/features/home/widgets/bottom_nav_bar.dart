import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey[600],
      showUnselectedLabels: true,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          activeIcon: Icon(Icons.map),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.photo_album_outlined),
          activeIcon: Icon(Icons.photo_album),
          label: 'Album',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.card_travel),
          activeIcon: Icon(Icons.card_travel),
          label: 'Trips',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.stars_outlined),
          activeIcon: Icon(Icons.stars),
          label: 'Quests',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag_outlined),
          activeIcon: Icon(Icons.shopping_bag),
          label: 'Shop',
        ),
      ],
    );
  }
}
