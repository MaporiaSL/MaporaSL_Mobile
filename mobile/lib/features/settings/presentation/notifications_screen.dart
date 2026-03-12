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

  bool _achievementsEnabled = true;
  bool _tripsEnabled = true;
  bool _placesEnabled = true;
  bool _socialEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotificationSettings();
  }

  Future<void> _fetchNotificationSettings() async {
    try {
      // In a fully integrated version, we'd fetch the existing user preferences via a GET endpoint.
      // E.g. final response = await _apiClient.get('/api/users/${user.uid}/profile');
      // For now we will rely on defaults or local state to avoid throwing an error
      // if the GET route isn't returning this nested object yet.
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateNotificationSettings() async {
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
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update mapping: $e')),
        );
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  child: Text(
                    'Push Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildToggle(
                        title: 'Achievements',
                        subtitle: 'Alerts when you unlock badges or districts',
                        icon: Icons.emoji_events_outlined,
                        value: _achievementsEnabled,
                        onChanged: (val) => setState(() => _achievementsEnabled = val),
                      ),
                      const Divider(height: 1),
                      _buildToggle(
                        title: 'Trip Reminders',
                        subtitle: 'Helpful reminders for upcoming planned trips',
                        icon: Icons.card_travel_outlined,
                        value: _tripsEnabled,
                        onChanged: (val) => setState(() => _tripsEnabled = val),
                      ),
                      const Divider(height: 1),
                      _buildToggle(
                        title: 'Place Submissions',
                        subtitle: 'Updates on places you suggested (approved/rejected)',
                        icon: Icons.add_location_alt_outlined,
                        value: _placesEnabled,
                        onChanged: (val) => setState(() => _placesEnabled = val),
                      ),
                      const Divider(height: 1),
                      _buildToggle(
                        title: 'Social Activity',
                        subtitle: 'When friends like or share your trips',
                        icon: Icons.people_outline,
                        value: _socialEnabled,
                        onChanged: (val) => setState(() => _socialEnabled = val),
                      ),
                    ],
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
              ],
            ),
    );
  }
}
