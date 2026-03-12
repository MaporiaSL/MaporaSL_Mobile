import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/api_client.dart';
import 'delete_account_screen.dart';

class PrivacyLocationScreen extends StatefulWidget {
  const PrivacyLocationScreen({super.key});

  @override
  State<PrivacyLocationScreen> createState() => _PrivacyLocationScreenState();
}

class _PrivacyLocationScreenState extends State<PrivacyLocationScreen> {
  final _apiClient = ApiClient();
  final _authService = AuthService();

  bool _isGpsEnabled = false;
  bool _locationOnlyDuringCheckins = true;
  bool _isPhotoPrivate = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _fetchPrivacySettings();
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.location.status;
    setState(() {
      _isGpsEnabled = status.isGranted;
    });
  }

  Future<void> _handleGpsToggle(bool value) async {
    // If they want to turn it on
    if (value) {
      final status = await Permission.location.request();
      setState(() {
        _isGpsEnabled = status.isGranted;
      });
      if (status.isPermanentlyDenied) {
        // If denied, they need to go to OS Settings
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enable location permissions in App Settings.'),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: openAppSettings,
              ),
            ),
          );
        }
      }
    } else {
      // If they want to turn it off, direct to OS settings (we can't revoke our own permission)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('To disable location, please turn it off in system App Settings.'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: openAppSettings,
            ),
          ),
        );
      }
    }
  }

  Future<void> _fetchPrivacySettings() async {
    try {
      final user = _authService.currentUser;
      if (user == null) return;
      
      // We pull the privacy details alongside the user progress or profile. 
      // For now, if we don't have a specialized GET endpoint, we maintain local state or default to true/false.
      // E.g: final response = await _apiClient.get('/api/users/${user.uid}/profile');
      //
      // In a real implementation where GET /profile returns the user document,
      // we would map it here. We'll default to the standard setup config:
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updatePrivacySettings() async {
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      await _apiClient.put('/api/users/${user.uid}/privacy', data: {
        'isPhotoPrivate': _isPhotoPrivate,
        'locationDuringCheckinsOnly': _locationOnlyDuringCheckins,
      });
      
    } catch (e) {
      if (mounted) {
        String errMsg = 'Failed to save preferences';
        if (e is DioException && e.response != null) {
          errMsg = 'Backend Error: ${e.response?.statusCode} - ${e.response?.data}';
        } else {
          errMsg = e.toString();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errMsg, style: const TextStyle(fontSize: 12)),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _onPhotoPrivacyChanged(bool value) {
    setState(() {
      _isPhotoPrivate = value;
    });
    _updatePrivacySettings();
  }

  void _onLocationCheckinChanged(bool value) {
    setState(() {
      _locationOnlyDuringCheckins = value;
    });
    _updatePrivacySettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Location'),
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
              'Location Access',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('GPS Location Access'),
                  subtitle: const Text('Required for map exploration and check-ins'),
                  value: _isGpsEnabled,
                  onChanged: _handleGpsToggle,
                  secondary: const Icon(Icons.location_on_outlined),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Only use location during check-ins'),
                  subtitle: const Text('Prevents background location tracking'),
                  value: _locationOnlyDuringCheckins,
                  onChanged: _onLocationCheckinChanged,
                  secondary: const Icon(Icons.share_location),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: Text(
              'Content Privacy',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SwitchListTile(
              title: const Text('Private Photos by Default'),
              subtitle: const Text('Only you can see your uploaded check-in photos'),
              value: _isPhotoPrivate,
              onChanged: _onPhotoPrivacyChanged,
              secondary: const Icon(Icons.photo_library_outlined),
            ),
          ),

          const SizedBox(height: 32),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: Text(
              'Data Control',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
          ),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.delete_sweep, color: Colors.red),
              title: const Text(
                'Data Deletion Request',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text('Permanently delete your account and data'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DeleteAccountScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
