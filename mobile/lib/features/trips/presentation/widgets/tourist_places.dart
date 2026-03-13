import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class TouristPlaces extends StatelessWidget {
  const TouristPlaces({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {"name": "Mountain", "icon": Ionicons.image_outline},
      {"name": "Beach", "icon": Ionicons.water_outline},
      {"name": "Park", "icon": Ionicons.leaf_outline},
      {"name": "City", "icon": Ionicons.business_outline},
    ];

    return SizedBox(
      height: 90,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 15),
        itemBuilder: (context, index) {
          final isSelected = index == 0;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Colors.blue.shade50 : Colors.grey.shade50,
                  border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
                ),
                child: Icon(
                  categories[index]["icon"], 
                  color: isSelected ? Colors.blue : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                categories[index]["name"],
                style: TextStyle(
                  fontSize: 12, 
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.black87 : Colors.grey.shade600,
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
