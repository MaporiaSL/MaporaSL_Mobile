import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sri Lanka Travel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Use a color scheme based on a "tropical" color like teal
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const TravelHomePage(),
    );
  }
}

class TravelHomePage extends StatefulWidget {
  const TravelHomePage({super.key});

  @override
  State<TravelHomePage> createState() => _TravelHomePageState();
}

class _TravelHomePageState extends State<TravelHomePage> {
  // A simple list of data for our destinations
  // In a real app, this would come from an API
  final List<Map<String, String>> destinations = [
    {
      "name": "Kandy",
      "description": "The cultural capital, home to the Temple of the Tooth.",
      "icon": "temple"
    },
    {
      "name": "Ella",
      "description": "Famous for its stunning mountain views and train journey.",
      "icon": "train"
    },
    {
      "name": "Galle",
      "description": "Historic Dutch fort city with beaches and boutiques.",
      "icon": "fort"
    },
    {
      "name": "Sigiriya",
      "description": "The ancient 'Lion Rock' fortress and palace.",
      "icon": "rock"
    },
    {
      "name": "Mirissa",
      "description": "Popular for whale watching and beautiful beaches.",
      "icon": "whale"
    },
    {
      "name": "Arugam Bay",
      "description": "World-famous surfing destination on the east coast.",
      "icon": "surfing"
    },
  ];

  // Helper function to get an icon based on the string
  IconData _getIcon(String iconName) {
    switch (iconName) {
      case "temple":
        return Icons.account_balance;
      case "train":
        return Icons.train;
      case "fort":
        return Icons.fort;
      case "rock":
        return Icons.filter_hdr;
      case "whale":
        return Icons.waves;
      case "surfing":
        return Icons.surfing;
      default:
        return Icons.location_city;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Sri Lanka'),
        leading: const Icon(Icons.travel_explore),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- MAP SECTION ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Interactive Map',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            SizedBox(
              height: 300,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                clipBehavior: Clip.antiAlias, // Ensures the image respects the border radius
                child: InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(20.0),
                  minScale: 0.5,
                  maxScale: 4.0,
                  // We use Image.network to load a map of Sri Lanka.
                  // This avoids needing any special map SDKs or API keys.
                  child: Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1f/Sri_Lanka_administrative_divisions_map.png/800px-Sri_Lanka_administrative_divisions_map.png',
                    fit: BoxFit.contain,
                    // Show a loading indicator while the map image downloads
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    // Show an error icon if the map fails to load
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // --- DESTINATIONS LIST SECTION ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Popular Destinations',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            // We use Expanded here so the ListView takes up the remaining
            // space in the Column without causing a layout error.
            Expanded(
              child: ListView.builder(
                itemCount: destinations.length,
                itemBuilder: (context, index) {
                  final destination = destinations[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    child: ListTile(
                      leading: Icon(
                        _getIcon(destination['icon']!),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(destination['name']!),
                      subtitle: Text(destination['description']!),
                      onTap: () {
                        // In a real app, this would navigate to a details page
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Navigating to ${destination['name']}...'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}