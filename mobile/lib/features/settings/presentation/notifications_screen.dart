import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/api_client.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _apiClient = ApiClient();
  final _authService = AuthService();

  // Core notification toggles
  bool _achievementsEnabled = true;
  bool _tripsEnabled = true;
  bool _placesEnabled = true;
  bool _socialEnabled = true;
  // Extended notification toggles
  bool _nearbyTripsEnabled = true;
  bool _placeVisitsEnabled = true;
  bool _celebrationsEnabled = true;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchNotificationSettings();
  }

  /// Loads current notification preferences from the backend.
  Future<void> _fetchNotificationSettings() async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      final response =
          await _apiClient.get('/api/users/${user.uid}/settings');
      final notifications =
          response.data['notifications'] as Map<String, dynamic>?;

      if (notifications != null && mounted) {
        setState(() {
          _achievementsEnabled = notifications['achievements'] as bool? ?? true;
          _tripsEnabled = notifications['trips'] as bool? ?? true;
          _placesEnabled = notifications['places'] as bool? ?? true;
          _socialEnabled = notifications['social'] as bool? ?? true;
          _nearbyTripsEnabled = notifications['nearbyTrips'] as bool? ?? true;
          _placeVisitsEnabled = notifications['placeVisits'] as bool? ?? true;
          _celebrationsEnabled = notifications['celebrations'] as bool? ?? true;
        });
      }
    } catch (e) {
      // Silently fall back to defaults if the network call fails
      debugPrint('Failed to load notification settings: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Persists all notification preferences to the backend.
  Future<void> _updateNotificationSettings() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      await _apiClient.put(
        '/api/users/${user.uid}/notifications',
        data: {
          'achievements': _achievementsEnabled,
          'trips': _tripsEnabled,
          'places': _placesEnabled,
          'social': _socialEnabled,
          'nearbyTrips': _nearbyTripsEnabled,
          'placeVisits': _placeVisitsEnabled,
          'celebrations': _celebrationsEnabled,
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save notification settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildToggle({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
      value: value,
      onChanged: (val) {
        onChanged(val);
        _updateNotificationSettings();
      },
      secondary: Icon(icon, color: Colors.blueGrey),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildSectionHeader('Achievements & Exploration'),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildToggle(
                        title: 'Achievements Unlocked',
                        subtitle: 'Alerts when you unlock badges or districts',
                        icon: Icons.emoji_events_outlined,
                        value: _achievementsEnabled,
                        onChanged: (val) =>
                            setState(() => _achievementsEnabled = val),
                      ),
                      const Divider(height: 1),
                      _buildToggle(
                        title: 'Province/District Celebrations',
                        subtitle:
                            'Celebrate when you complete a region or province',
                        icon: Icons.celebration_outlined,
                        value: _celebrationsEnabled,
                        onChanged: (val) =>
                            setState(() => _celebrationsEnabled = val),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                _buildSectionHeader('Trips & Places'),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildToggle(
                        title: 'Trip Reminders',
                        subtitle: 'Helpful reminders for upcoming planned trips',
                        icon: Icons.card_travel_outlined,
                        value: _tripsEnabled,
                        onChanged: (val) => setState(() => _tripsEnabled = val),
                      ),
                      const Divider(height: 1),
                      _buildToggle(
                        title: 'New Curated Trips Nearby',
                        subtitle:
                            'Discover new trips curated for your area',
                        icon: Icons.explore_outlined,
                        value: _nearbyTripsEnabled,
                        onChanged: (val) =>
                            setState(() => _nearbyTripsEnabled = val),
                      ),
                      const Divider(height: 1),
                      _buildToggle(
                        title: 'Place Submission Status',
                        subtitle:
                            'Updates on places you suggested (approved/rejected)',
                        icon: Icons.add_location_alt_outlined,
                        value: _placesEnabled,
                        onChanged: (val) =>
                            setState(() => _placesEnabled = val),
                      ),
                      const Divider(height: 1),
                      _buildToggle(
                        title: 'Place Visit Notifications',
                        subtitle: 'When someone visits a place you contributed',
                        icon: Icons.location_on_outlined,
                        value: _placeVisitsEnabled,
                        onChanged: (val) =>
                            setState(() => _placeVisitsEnabled = val),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                _buildSectionHeader('Social'),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _buildToggle(
                    title: 'Social Activity',
                    subtitle: 'When friends like or share your trips',
                    icon: Icons.people_outline,
                    value: _socialEnabled,
                    onChanged: (val) => setState(() => _socialEnabled = val),
                  ),
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'System notifications can also be managed in your device settings.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
    );
  }
}
