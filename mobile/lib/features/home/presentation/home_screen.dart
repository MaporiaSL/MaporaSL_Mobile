import 'package:flutter/material.dart';
import '../../map/presentation/map_screen.dart';
import '../../album/presentation/album_page.dart';
import '../../trips/presentation/trips_page.dart';
import '../../trips/presentation/memory_lane_page.dart';
import '../../shop/presentation/shop_page.dart';
import '../../profile/presentation/profile_screen.dart';
import '../widgets/bottom_nav_bar.dart';

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
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}
