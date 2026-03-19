import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../map/presentation/map_screen.dart';
import '../../album/presentation/album_page.dart';
import '../../trips/presentation/trips_page.dart';
import '../../trips/presentation/memory_lane_page.dart';
import '../../shop/presentation/shop_page.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../profile/presentation/first_time_profile_setup_screen.dart';
import '../../profile/presentation/providers/profile_providers.dart';
import '../../auth/services/auth_gate.dart';
import '../widgets/bottom_nav_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    MapScreen(travelId: 'default'), // 0 Map
    AlbumPage(), // 1 Album
    TripsPage(), // 2 Trips
    MemoryLanePage(), // 3 Timeline
    ShopPage(), // 4 Shop
  ];

  @override
  Widget build(BuildContext context) {
    final guardState = ref.watch(coreNavigationGuardProvider);

    return guardState.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Unable to verify profile setup right now.'),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    ref.invalidate(coreNavigationGuardProvider);
                    ref.invalidate(profileBootstrapProvider);
                    ref.invalidate(profileSetupRequirementProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (guard) {
        if (guard.requiresSignIn) {
          return const AuthGate();
        }

        if (guard.requiresSetup) {
          return FirstTimeProfileSetupScreen(
            requiredFields: guard.requiredFields,
            optionalFields: guard.optionalFields,
          );
        }

        if (!guard.isAllowed) {
          return Scaffold(
            body: Center(
              child: Text(
                guard.message ?? 'Access blocked until setup is complete.',
              ),
            ),
          );
        }

        return Scaffold(
          body: Stack(
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
      },
    );
  }
}
