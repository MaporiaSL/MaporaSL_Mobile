import 'package:flutter/material.dart';
import '../../map/presentation/map_screen.dart';
import '../../album/presentation/album_page.dart';
import '../../trips/presentation/trips_page.dart';
import '../../trips/presentation/memory_lane_page.dart';
import '../../shop/presentation/shop_page.dart';
import '../../profile/presentation/profile_screen.dart';
import '../widgets/bottom_nav_bar.dart';

import '../../places/screens/places_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Start with Trips as default

  final List<Widget> _screens = const [
    MapScreen(travelId: 'default'), // 0 Map
    AlbumPage(), // 1 Album
    TripsPage(), // 2 Trips
    MemoryLanePage(), // 3 Timeline
    ShopPage(), // 4 Shop
    ProfileScreen(), // 5 Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _screens[_selectedIndex],
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: Column(
              children: [
                _buildFloatingButton(
                  icon: Icons.person_outline,
                  onTap: () => setState(() => _selectedIndex = 5),
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildFloatingButton(
                  icon: Icons.location_on_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PlacesListScreen()),
                    );
                  },
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      elevation: 4,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Icon(icon, color: color, size: 28),
        ),
      ),
    );
  }
}
