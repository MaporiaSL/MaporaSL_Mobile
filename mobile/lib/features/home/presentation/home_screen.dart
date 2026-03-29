import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../map/presentation/map_screen.dart';
import '../../album/presentation/album_page.dart';
import '../../trips/presentation/trips_page.dart';
import '../../trips/presentation/memory_lane_page.dart';
import '../../shop/presentation/shop_page.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../places/presentation/add_destination_page.dart';
import '../widgets/bottom_nav_bar.dart';
import '../../../core/services/auth_api.dart';
import '../../../core/services/local_prefs.dart';
import 'providers/home_providers.dart';
import '../../profile/presentation/providers/profile_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 2;
  bool _isCheckingProfile = true;

  final List<String> _labels = [
    'Album',
    'Trips',
    'Explore',
    'Expedition',
    'Shop',
  ];

  final List<Widget> _screens = const [
    AlbumPage(), // 0 Album
    TripsPage(), // 1 Trips
    MapScreen(travelId: 'default'), // 2 Map
    MemoryLanePage(), // 3 Expedition Hub
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
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (!mounted) return;
        setState(() => _isCheckingProfile = false);
        return;
      }
      final email = user.email ?? 'unknown@local.test';
      final name = user.displayName ?? email.split('@').first;
      final district = await LocalPrefs.getHometownDistrict() ?? 'Colombo';
      try {
        await AuthApi().registerUser(
          email: email,
          name: name,
          hometownDistrict: district,
        );
        await LocalPrefs.clearHometownDistrict();
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
    final isDistrictFocused = ref.watch(districtFocusProvider);
    final selectedIndex = ref.watch(homeSelectedIndexProvider);

    return Scaffold(
      body: _isCheckingProfile
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                _screens[selectedIndex],
                if (selectedIndex == 2)
                  Positioned(
                    right: 16,
                    bottom: 96,
                    child: SafeArea(
                      child: FloatingActionButton(
                        heroTag: 'add_gem_btn',
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddDestinationPage(),
                            ),
                          );
                        },
                        child: const Icon(Icons.add_location_alt),
                      ),
                    ),
                  ),
                if (!isDistrictFocused)
                  Positioned(
                    top: 10,
                    right: 16,
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
                          borderRadius: BorderRadius.circular(25),
                          child: Consumer(
                            builder: (context, ref, _) {
                              final profile = ref.watch(userProfileProvider).valueOrNull;
                              final avatarUrl = profile?.avatarUrl ?? '';
                              final isDark = Theme.of(context).brightness == Brightness.dark;
                              
                              return Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark ? Colors.black45 : Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDark ? Colors.black54 : Colors.black26,
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                  border: Border.all(
                                    color: isDark ? Colors.white10 : Colors.blue.shade100,
                                    width: 2,
                                  ),
                                ),
                                child: ClipOval(
                                  child: avatarUrl.isNotEmpty
                                      ? Image.network(
                                          avatarUrl,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, progress) {
                                            if (progress == null) return child;
                                            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                                          },
                                          errorBuilder: (context, _, __) => Icon(
                                            Icons.person_rounded,
                                            color: isDark ? Colors.white38 : Colors.grey.shade400,
                                            size: 32,
                                          ),
                                        )
                                      : Icon(
                                          Icons.person_rounded,
                                          color: isDark ? Colors.white38 : Colors.grey.shade400,
                                          size: 32,
                                        ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                // Bottom gradient for navigation bar separation
                if (!isDistrictFocused)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 120,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.3),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          if (index == 2 && selectedIndex == 2) {
            // Reset district focus if tapping map again while active
            ref.read(districtFocusProvider.notifier).state = false;
          }
          ref.read(homeSelectedIndexProvider.notifier).state = index;
        },
      ),
    );
  }
}
