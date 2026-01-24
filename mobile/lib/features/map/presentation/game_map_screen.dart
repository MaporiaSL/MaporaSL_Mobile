import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../../core/constants/map_constants.dart';

/// GameMapScreen - Main map interface with gamification features
/// Displays Sri Lanka map with custom game-styled theme,
/// fog of war overlay, and destination markers
class GameMapScreen extends StatefulWidget {
  const GameMapScreen({super.key});

  @override
  State<GameMapScreen> createState() => _GameMapScreenState();
}

class _GameMapScreenState extends State<GameMapScreen> {
  MapboxMap? _mapboxMap;
  bool _isStyleLoaded = false;
  int _selectedBottomNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Custom app bar
      appBar: AppBar(
        elevation: 4,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'Maporia',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          // Profile icon
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile clicked')),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.account_circle,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main map widget
          MapWidget(
            key: const ValueKey("gameMapWidget"),
            cameraOptions: CameraOptions(
              center: MapConstants.sriLankaCenter,
              zoom: MapConstants.defaultZoom,
            ),
            onMapCreated: _onMapCreated,
          ),

          // Loading indicator while style loads
          if (!_isStyleLoaded) const Center(child: CircularProgressIndicator()),
        ],
      ),
      // Bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedBottomNavIndex,
        onTap: (index) {
          setState(() {
            _selectedBottomNavIndex = index;
          });
          _handleBottomNavigation(index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Quests'),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  void _handleBottomNavigation(int index) {
    switch (index) {
      case 0:
        // Map screen (already here)
        break;
      case 1:
        // Quests
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quests section - Coming soon!')),
        );
        break;
      case 2:
        // Inventory
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inventory section - Coming soon!')),
        );
        break;
      case 3:
        // Settings
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings section - Coming soon!')),
        );
        break;
    }
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    // Load custom game style
    await mapboxMap.loadStyleURI(MapConstants.gameStyleUrl);

    setState(() {
      _isStyleLoaded = true;
    });

    // Set map bounds to Sri Lanka
    await mapboxMap.setBounds(
      CameraBoundsOptions(
        bounds: MapConstants.sriLankaBounds,
        minZoom: MapConstants.minZoom,
        maxZoom: MapConstants.maxZoom,
      ),
    );

    print('✅ Game map initialized with custom style');
  }

  @override
  void dispose() {
    _mapboxMap = null;
    super.dispose();
  }
}
