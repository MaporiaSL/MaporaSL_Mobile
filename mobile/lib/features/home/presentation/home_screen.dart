import 'package:flutter/material.dart';
import '../../map/presentation/map_screen.dart';
import '../../album/presentation/album_page.dart';
import '../../trips/presentation/trips_page.dart';
import '../../trips/presentation/memory_lane_page.dart';
import '../../shop/presentation/shop_page.dart';
import '../../profile/presentation/profile_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import '../../../core/services/auth_api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isCheckingProfile = true;

  final List<Widget> _screens = const [
    MapScreen(travelId: 'default'), // 0 Map
    AlbumPage(), // 1 Album
    TripsPage(), // 2 Trips
    MemoryLanePage(), // 3 Timeline
    ShopPage(), // 4 Shop
  ];

  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    try {
      await AuthApi().getMe();
      if (!mounted) return;
      setState(() {
        _isCheckingProfile = false;
      });
    } catch (_) {
      try {
        await AuthApi().registerUser(
          email: 'dev@local.test',
          name: 'Dev User',
          hometownDistrict: 'Colombo',
        );
      } catch (_) {
        // Swallow registration errors during dev flow.
      }
      if (!mounted) return;
      setState(() {
        _isCheckingProfile = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isCheckingProfile
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                _screens[_selectedIndex],
                Positioned(
                  top: 12,
                  right: 12,
                  child: SafeArea(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfileScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.9),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.7),
                              width: 1.5,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const CircleAvatar(
                            backgroundColor: Colors.transparent,
                            child: Icon(Icons.person, color: Colors.black87),
                          ),
                        ),
                      ),
                    ),
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
}
