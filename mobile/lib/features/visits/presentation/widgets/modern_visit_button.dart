import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/accessibility_provider.dart';

class ModernVisitButton extends ConsumerWidget {
  final bool isVisited;
  final VoidCallback onTap;

  const ModernVisitButton({
    super.key,
    required this.isVisited,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessibility = ref.watch(accessibilityProvider);
    final useAnimations = accessibility.useAnimations;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: useAnimations 
            ? const Duration(milliseconds: 300)
            : Duration.zero,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: LinearGradient(
            colors: isVisited 
                ? [Colors.teal.shade400, Colors.teal.shade700]
                : [Colors.indigo.shade400, Colors.purple.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: (isVisited ? Colors.teal : Colors.purple).withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isVisited ? Icons.check_circle_outline : Icons.location_on_outlined,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              isVisited ? 'Visited' : 'Mark Visit',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

