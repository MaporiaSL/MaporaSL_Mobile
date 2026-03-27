import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

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

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: CurvedNavigationBar(
        index: currentIndex,
        color: Colors.blue.shade700,
        buttonBackgroundColor: Colors.blue.shade900,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        onTap: onTap,
        height: 70, // Slightly reduced height to keep it elegant
        items: <Widget>[
          _buildNavItem(
            Icons.photo_album,
            Icons.photo_album_outlined,
            'Album',
            0,
          ),
          _buildNavItem(Icons.card_travel, Icons.card_travel, 'Trips', 1),
          _buildNavItem(Icons.map, Icons.map_outlined, 'Map', 2),
          _buildNavItem(Icons.history, Icons.history_outlined, 'Timeline', 3),
          _buildNavItem(
            Icons.shopping_bag,
            Icons.shopping_bag_outlined,
            'Shop',
            4,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
    int index,
  ) {
    final isActive = currentIndex == index;
    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isActive ? activeIcon : inactiveIcon,
            size: isActive ? 35 : 29,
            color: Colors.white,
          ),
          if (!isActive)
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
