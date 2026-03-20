import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import 'custom_trip_builder_page.dart';
import 'widgets/custom_icon_button.dart';
import 'widgets/location_card.dart';
import 'widgets/nearby_places.dart';
import 'widgets/recommended_places.dart';

class TripsPage extends StatelessWidget {
  const TripsPage({super.key});

  static const List<_QuestCardData> _completedQuests = [
    _QuestCardData(
      title: 'Ancient Kingdom Run',
      subtitle: 'Polonnaruwa and Sigiriya circuit',
      days: 4,
    ),
    _QuestCardData(
      title: 'Southern Shore Sprint',
      subtitle: 'Galle, Mirissa and Hikkaduwa',
      days: 3,
    ),
    _QuestCardData(
      title: 'Highland Heritage',
      subtitle: 'Nuwara Eliya and Horton Plains',
      days: 4,
    ),
  ];

  static const List<_QuestCardData> _customQuests = [
    _QuestCardData(
      title: 'Tea Trails Escape',
      subtitle: 'Nuwara Eliya to Ella with train rides',
      days: 5,
    ),
    _QuestCardData(
      title: 'Northern Stories',
      subtitle: 'Jaffna food, forts and island hops',
      days: 4,
    ),
    _QuestCardData(
      title: 'Wild & Coastal Mix',
      subtitle: 'Yala safari plus south beach sunsets',
      days: 4,
    ),
  ];

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

          // COMPLETED QUESTS
          Text('Your Triumphs', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          _buildCompletedTrips(context),
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

          // CUSTOM QUESTS
          Text('Custom Quests', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          _buildCustomTrips(context),
        ],
      ),
      // Notice: No bottomNavigationBar here!
      // This allows your main CurvedNavigationBar to handle the menu.
    );
  }

  Widget _buildCompletedTrips(BuildContext context) {
    return SizedBox(
      height: 170,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: _completedQuests.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final quest = _completedQuests[index];
          return Container(
            width: 230,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: const Color(0xFFFFF7E3),
              border: Border.all(color: const Color(0xFFEAD9AA)),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quest.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      quest.subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${quest.days} Days Completed',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const Positioned(
                  right: 0,
                  top: 0,
                  child: Icon(
                    Ionicons.checkmark_circle,
                    color: Color(0xFF22A447),
                    size: 30,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomTrips(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: _customQuests.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const CustomTripBuilderPage(),
                  ),
                );
              },
              child: Container(
                width: 240,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: const Color(0xFFF2F8FF),
                  border: Border.all(
                    color: const Color(0xFF9CC4EF),
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Ionicons.add_circle_outline,
                      color: Color(0xFF2C6DB9),
                      size: 46,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Create Custom Trip based on your likes',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final quest = _customQuests[index - 1];
          return Container(
            width: 230,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white,
              border: Border.all(color: const Color(0xFFD8E5F6)),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueGrey.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFE8F2FF),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: const Icon(
                    Ionicons.map_outline,
                    color: Color(0xFF2C6DB9),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  quest.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  quest.subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(
                      Ionicons.timer_outline,
                      size: 14,
                      color: Color(0xFF2C6DB9),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${quest.days} Days',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
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
