import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/preplanned_trips_provider.dart';
import 'preplanned_trip_detail_sheet.dart';

class RecommendedPlaces extends ConsumerWidget {
  const RecommendedPlaces({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preplannedAsync = ref.watch(preplannedTripsFutureProvider);

    return SizedBox(
      height: 250,
      child: preplannedAsync.when(
        data: (trips) {
          if (trips.isEmpty) {
            return const Center(child: Text("No recommendations found."));
          }

          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: trips.length,
            separatorBuilder: (context, index) => const SizedBox(width: 15),
            itemBuilder: (context, index) {
              final trip = trips[index];
              return InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => PrePlannedTripDetailSheet(trip: trip),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          color: Colors.blue.shade100,
                          // If you implement imageUrls in PrePlannedTrip schema later, you can use Image.network here!
                        ),
                        child: const Center(
                          child: Icon(Icons.terrain, size: 50, color: Colors.blue),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trip.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.orange.shade400, size: 16),
                                const Text(
                                  " 4.8", 
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.timer_outlined, size: 12, color: Colors.blue.shade700),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${trip.durationDays} Days",
                                        style: TextStyle(
                                          fontSize: 12, 
                                          fontWeight: FontWeight.bold, 
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Failed to load recommendations: $err")),
      ),
    );
  }
}
