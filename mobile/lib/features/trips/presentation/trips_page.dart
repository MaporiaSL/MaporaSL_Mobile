import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import 'widgets/custom_icon_button.dart';
import 'widgets/location_card.dart';
import 'widgets/nearby_places.dart';
import 'widgets/recommended_places.dart';

class TripsPage extends StatelessWidget {
  const TripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Good Morning"),
            Text(
              "Adventurer", // You can change this to your user's name!
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        actions: const [
          CustomIconButton(icon: Icon(Ionicons.search_outline)),
          Padding(
            padding: EdgeInsets.only(left: 8.0, right: 12),
            child: CustomIconButton(icon: Icon(Ionicons.notifications_outline)),
          ),
        ],
      ),
      // This is the exact body layout from the tutorial's home_page.dart
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(14),
        children: [
          // LOCATION CARD
          const LocationCard(),
          const SizedBox(height: 15),

          // CATEGORIES (Mountain, Beach, etc.)
          //const TouristPlaces(),
          //const SizedBox(height: 10),

          // RECOMMENDATIONS LIST
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
<<<<<<< HEAD
              Text(
                "Recommendation",
                style: Theme.of(context).textTheme.titleLarge,
=======
              // Image Section
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  color: Colors.grey.shade200,
                  child:
                      place.photos.isNotEmpty
                          ? Image.network(
                            place.photos.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.image_not_supported);
                            },
                          )
                          : const Icon(Icons.place, size: 32),
                ),
              ),
              // Info Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        place.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        distanceText,
                        style: TextStyle(fontSize: 13, color: Colors.blue.shade700, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 2),
                      Expanded(
                        child: Text(
                          place.description ?? '',
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.chevron_right, color: Colors.grey),
>>>>>>> origin/timeline-kaushal
              ),
              TextButton(onPressed: () {}, child: const Text("View All")),
            ],
          ),
          const SizedBox(height: 10),
          const RecommendedPlaces(),
          const SizedBox(height: 10),

          // NEARBY FROM YOU LIST
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Nearby From You",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(onPressed: () {}, child: const Text("View All")),
            ],
          ),
          const SizedBox(height: 10),
          const NearbyPlaces(),
        ],
      ),
      // Notice: No bottomNavigationBar here!
      // This allows your main CurvedNavigationBar to handle the menu.
    );
  }
}
