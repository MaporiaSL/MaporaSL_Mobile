import '../data/models/trip_dto.dart';

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
        locations: ['Anuradhapura', 'Polonnaruwa', 'Sigiriya', 'Dambulla'],
      ),

      // Active Quest 2
      CreateTripDto(
        title: 'Hill Country Tea Trail',
        description:
            'From mist-covered mountains to rolling tea estates. Discovering the heart of Ceylon tea country.',
        startDate: now.subtract(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 6)),
        locations: ['Nuwara Eliya', 'Ella', 'Haputale', 'Bandarawela'],
      ),

      // Planned Adventure 1
      CreateTripDto(
        title: 'Southern Coast Paradise',
        description:
            'Beach hopping along the golden southern shores. Sun, surf, and sea turtles!',
        startDate: now.add(const Duration(days: 14)),
        endDate: now.add(const Duration(days: 21)),
        locations: ['Galle', 'Mirissa', 'Tangalle', 'Weligama', 'Unawatuna'],
      ),

      // Planned Adventure 2
      CreateTripDto(
        title: 'Northern Heritage Discovery',
        description:
            'Uncovering the rich Tamil culture and historical sites of the Northern Province.',
        startDate: now.add(const Duration(days: 30)),
        endDate: now.add(const Duration(days: 37)),
        locations: ['Jaffna', 'Mannar', 'Vavuniya'],
      ),

      // Planned Adventure 3
      CreateTripDto(
        title: 'East Coast Sunrise Quest',
        description:
            'Pristine beaches where the sun rises over the Bay of Bengal. Surfing and serenity.',
        startDate: now.add(const Duration(days: 45)),
        endDate: now.add(const Duration(days: 52)),
        locations: ['Trincomalee', 'Arugam Bay', 'Batticaloa', 'Pasikuda'],
      ),

      // Completed Journey 1
      CreateTripDto(
        title: 'Colombo City Explorer',
        description:
            'Urban adventures in the commercial capital. Markets, museums, and modern marvels.',
        startDate: now.subtract(const Duration(days: 60)),
        endDate: now.subtract(const Duration(days: 56)),
        locations: [
          'Colombo Fort',
          'Pettah Market',
          'Galle Face Green',
          'National Museum',
        ],
      ),

      // Completed Journey 2
      CreateTripDto(
        title: 'Kandy Perahera Festival',
        description:
            'Witnessed the grand Esala Perahera procession. Elephants, dancers, and ancient traditions.',
        startDate: now.subtract(const Duration(days: 90)),
        endDate: now.subtract(const Duration(days: 85)),
        locations: [
          'Temple of the Tooth',
          'Kandy Lake',
          'Peradeniya Botanical Gardens',
        ],
      ),

      // Completed Journey 3
      CreateTripDto(
        title: 'Sinharaja Rainforest Trek',
        description:
            'Deep into the heart of Sri Lanka\'s biodiversity hotspot. Endemic species galore!',
        startDate: now.subtract(const Duration(days: 120)),
        endDate: now.subtract(const Duration(days: 118)),
        locations: ['Sinharaja Forest Reserve', 'Deniyaya'],
      ),

      // Completed Journey 4
      CreateTripDto(
        title: 'Adams Peak Pilgrimage',
        description:
            'Climbed Sri Pada at dawn to witness the sacred footprint and sunrise over the clouds.',
        startDate: now.subtract(const Duration(days: 150)),
        endDate: now.subtract(const Duration(days: 149)),
        locations: ['Nallathanniya', 'Adams Peak Summit'],
      ),

      // Completed Journey 5
      CreateTripDto(
        title: 'Yala Wildlife Safari',
        description:
            'Spotted leopards, elephants, and sloth bears in their natural habitat. Unforgettable!',
        startDate: now.subtract(const Duration(days: 180)),
        endDate: now.subtract(const Duration(days: 177)),
        locations: ['Yala National Park', 'Tissamaharama', 'Kataragama'],
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
      locations: ['Location A', 'Location B', 'Location C'],
    );
  }
}
