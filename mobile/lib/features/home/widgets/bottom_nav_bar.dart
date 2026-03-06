import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/constants/app_colors.dart';

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
    final navItems = [
      {'icon': Icons.map_outlined, 'activeIcon': Icons.map, 'label': 'Map'},
      {'icon': Icons.photo_album_outlined, 'activeIcon': Icons.photo_album, 'label': 'Album'},
      {'icon': Icons.card_travel, 'activeIcon': Icons.card_travel, 'label': 'Trips'},
      {'icon': Icons.stars_outlined, 'activeIcon': Icons.stars, 'label': 'Quests'},
      {'icon': Icons.shopping_bag_outlined, 'activeIcon': Icons.shopping_bag, 'label': 'Shop'},
    ];

    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Stack(
        children: [
          // Glass Background
          Positioned.fill(
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark 
                        ? Colors.black.withOpacity(0.6) 
                        : Colors.white.withOpacity(0.7),
                    border: Border(
                      top: BorderSide(
                        color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                        width: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Buttons
          Row(
            children: List.generate(navItems.length, (index) {
              final isSelected = currentIndex == index;
              final item = navItems[index];
              final activeColor = isDark ? const Color(0xFF10B981) : const Color(0xFF059669); // Emerald
              final color = isSelected 
                  ? activeColor
                  : (isDark ? Colors.white38 : Colors.black38);

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  highlightColor: Colors.transparent,
                  splashColor: activeColor.withOpacity(0.1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? activeColor.withOpacity(0.1) : Colors.transparent,
                        ),
                        child: Icon(
                          isSelected ? item['activeIcon'] as IconData : item['icon'] as IconData,
                          color: color,
                          size: isSelected ? 26 : 24,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['label'] as String,
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
