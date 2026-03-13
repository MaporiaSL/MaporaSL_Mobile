import '../data/models/trip_dto.dart';
import '../data/models/trip_model.dart';

/// Generate sample trips for testing
class SampleTripsGenerator {
  static List<CreateTripDto> getSampleTrips() {
    final now = DateTime.now();

    return [
      // Active Quest 1
      CreateTripDto(
        title: 'Cultural Triangle Expedition',
        description:
            'Exploring ancient kingdoms: Anuradhapura, Polonnaruwa, and Sigiriya. A journey through 2000 years of history.',
        startDate: now.subtract(const Duration(days: 3)),
        endDate: now.add(const Duration(days: 4)),
        locations: const [
          TripLocation(name: 'Anuradhapura', day: 1),
          TripLocation(name: 'Polonnaruwa', day: 2),
          TripLocation(name: 'Sigiriya', day: 3),
          TripLocation(name: 'Dambulla', day: 4),
        ],
      ),

      // Active Quest 2
      CreateTripDto(
        title: 'Hill Country Tea Trail',
        description:
            'From mist-covered mountains to rolling tea estates. Discovering the heart of Ceylon tea country.',
        startDate: now.subtract(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 6)),
        locations: const [
          TripLocation(name: 'Nuwara Eliya', day: 1),
          TripLocation(name: 'Ella', day: 2),
          TripLocation(name: 'Haputale', day: 3),
          TripLocation(name: 'Bandarawela', day: 4),
        ],
      ),

      // Planned Adventure 1
      CreateTripDto(
        title: 'Southern Coast Paradise',
        description:
            'Beach hopping along the golden southern shores. Sun, surf, and sea turtles!',
        startDate: now.add(const Duration(days: 14)),
        endDate: now.add(const Duration(days: 21)),
        locations: const [
          TripLocation(name: 'Galle', day: 1),
          TripLocation(name: 'Mirissa', day: 2),
          TripLocation(name: 'Tangalle', day: 3),
          TripLocation(name: 'Weligama', day: 4),
          TripLocation(name: 'Unawatuna', day: 5),
        ],
      ),

      // Planned Adventure 2
      CreateTripDto(
        title: 'Northern Heritage Discovery',
        description:
            'Uncovering the rich Tamil culture and historical sites of the Northern Province.',
        startDate: now.add(const Duration(days: 30)),
        endDate: now.add(const Duration(days: 37)),
        locations: const [
          TripLocation(name: 'Jaffna', day: 1),
          TripLocation(name: 'Mannar', day: 2),
          TripLocation(name: 'Vavuniya', day: 3),
        ],
      ),

      // Planned Adventure 3
      CreateTripDto(
        title: 'East Coast Sunrise Quest',
        description:
            'Pristine beaches where the sun rises over the Bay of Bengal. Surfing and serenity.',
        startDate: now.add(const Duration(days: 45)),
        endDate: now.add(const Duration(days: 52)),
        locations: const [
          TripLocation(name: 'Trincomalee', day: 1),
          TripLocation(name: 'Arugam Bay', day: 2),
          TripLocation(name: 'Batticaloa', day: 3),
          TripLocation(name: 'Pasikuda', day: 4),
        ],
      ),

      // Completed Journey 1
      CreateTripDto(
        title: 'Colombo City Explorer',
        description:
            'Urban adventures in the commercial capital. Markets, museums, and modern marvels.',
        startDate: now.subtract(const Duration(days: 60)),
        endDate: now.subtract(const Duration(days: 56)),
        locations: const [
          TripLocation(name: 'Colombo Fort', day: 1),
          TripLocation(name: 'Pettah Market', day: 2),
          TripLocation(name: 'Galle Face Green', day: 3),
          TripLocation(name: 'National Museum', day: 4),
        ],
      ),

      // Completed Journey 2
      CreateTripDto(
        title: 'Kandy Perahera Festival',
        description:
            'Witnessed the grand Esala Perahera procession. Elephants, dancers, and ancient traditions.',
        startDate: now.subtract(const Duration(days: 90)),
        endDate: now.subtract(const Duration(days: 85)),
        locations: const [
          TripLocation(name: 'Temple of the Tooth', day: 1),
          TripLocation(name: 'Kandy Lake', day: 2),
          TripLocation(name: 'Peradeniya Botanical Gardens', day: 3),
        ],
      ),

      // Completed Journey 3
      CreateTripDto(
        title: 'Sinharaja Rainforest Trek',
        description:
            'Deep into the heart of Sri Lanka\'s biodiversity hotspot. Endemic species galore!',
        startDate: now.subtract(const Duration(days: 120)),
        endDate: now.subtract(const Duration(days: 118)),
        locations: const [
          TripLocation(name: 'Sinharaja Forest Reserve', day: 1),
          TripLocation(name: 'Deniyaya', day: 2),
        ],
      ),

      // Completed Journey 4
      CreateTripDto(
        title: 'Adams Peak Pilgrimage',
        description:
            'Climbed Sri Pada at dawn to witness the sacred footprint and sunrise over the clouds.',
        startDate: now.subtract(const Duration(days: 150)),
        endDate: now.subtract(const Duration(days: 149)),
        locations: const [
          TripLocation(name: 'Nallathanniya', day: 1),
          TripLocation(name: 'Adams Peak Summit', day: 2),
        ],
      ),

      // Completed Journey 5
      CreateTripDto(
        title: 'Yala Wildlife Safari',
        description:
            'Spotted leopards, elephants, and sloth bears in their natural habitat. Unforgettable!',
        startDate: now.subtract(const Duration(days: 180)),
        endDate: now.subtract(const Duration(days: 177)),
        locations: const [
          TripLocation(name: 'Yala National Park', day: 1),
          TripLocation(name: 'Tissamaharama', day: 2),
          TripLocation(name: 'Kataragama', day: 3),
        ],
      ),
    ];
  }

  /// Generate a quick test trip
  static CreateTripDto getQuickTestTrip() {
    final now = DateTime.now();
    return CreateTripDto(
      title: 'Test Quest ${now.millisecondsSinceEpoch}',
      description: 'Auto-generated test trip for debugging',
      startDate: now,
      endDate: now.add(const Duration(days: 7)),
      locations: const [
        TripLocation(name: 'Location A', day: 1),
        TripLocation(name: 'Location B', day: 2),
        TripLocation(name: 'Location C', day: 3),
      ],
    );
  }
}
