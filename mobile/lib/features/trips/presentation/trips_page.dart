import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import 'create_trip_page.dart';
import 'widgets/custom_icon_button.dart';
import 'widgets/location_card.dart';
import 'widgets/nearby_places.dart';
import 'widgets/recommended_places.dart';

class TripsPage extends StatelessWidget {
  const TripsPage({super.key});

  // Static quest/trip data removed to follow separation of concerns:
  // Discovery Page (Trips) vs History/Management (Timeline)


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
          const SizedBox(height: 20),

          // CATEGORIES (Mountain, Beach, etc.)
          //const TouristPlaces(),
          //const SizedBox(height: 10),

          // RECOMMENDATIONS LIST
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recommendation",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const AllRecommendationsPage(),
                    ),
                  );
                },
                child: const Text("View All"),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const RecommendedPlaces(),
          const SizedBox(height: 20),


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
          const SizedBox(height: 20),

          // CREATE CUSTOM TRIP ACTION
          Text('Plan Your Own Adventure', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _buildCreateTripCard(context),
          const SizedBox(height: 30),
        ],
      ),
      // Notice: No bottomNavigationBar here!
      // This allows your main CurvedNavigationBar to handle the menu.
    );
  }

  Widget _buildCreateTripCard(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => const CreateTripPage(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Column(
          children: [
            Icon(
              Ionicons.add_circle,
              color: Colors.white,
              size: 48,
            ),
            SizedBox(height: 12),
            Text(
              'Create Custom Trip',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Build an itinerary based on your likes',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }


}

class _QuestCardData {
  final String title;
  final String subtitle;
  final int days;

  const _QuestCardData({
    required this.title,
    required this.subtitle,
    required this.days,
  });
}

class AllRecommendationsPage extends StatelessWidget {
  const AllRecommendationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Recommendations')),
      body: const Center(child: Text('All recommendations will appear here.')),
    );
  }
}
