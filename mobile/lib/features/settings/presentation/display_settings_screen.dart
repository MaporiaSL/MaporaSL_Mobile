import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart' as dio;
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/api_client.dart';

class DisplaySettingsScreen extends StatefulWidget {
  const DisplaySettingsScreen({super.key});

  @override
  State<DisplaySettingsScreen> createState() => _DisplaySettingsScreenState();
}

class _DisplaySettingsScreenState extends State<DisplaySettingsScreen> {
  final _apiClient = ApiClient();
  final _authService = AuthService();

  String _mapTheme = 'default';
  bool _cloudAnimation = true;
  String _units = 'km';
  String _language = 'English';
  bool _isLoading = true;

  final List<String> _availableLanguages = [
    'English',
    'Sinhala',
    'Tamil',
  ];

  @override
  void initState() {
    super.initState();
    _fetchDisplaySettings();
  }

  Future<void> _fetchDisplaySettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString('mapTheme');
      
      setState(() {
        if (savedTheme != null) {
          _mapTheme = savedTheme;
        }
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateDisplaySettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('mapTheme', _mapTheme);

      final user = _authService.currentUser;
      if (user == null) return;

      await _apiClient.put(
        '/api/users/${user.uid}/display',
        data: {
          'mapTheme': _mapTheme,
          'cloudAnimation': _cloudAnimation,
          'units': _units,
          'language': _language,
        },
      );
    } catch (e) {
      if (mounted) {
        String errMsg = 'Failed to update map settings';
        if (e is dio.DioException && e.response != null) {
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
        title: const Text('Map & Display'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildSectionHeader('Map Appearance'),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Map Theme',
                              style: TextStyle(fontSize: 16),
                            ),
                            DropdownButton<String>(
                              value: _mapTheme,
                              underline: const SizedBox(),
                              items: const [
                                DropdownMenuItem(value: 'default', child: Text('Default')),
                                DropdownMenuItem(value: 'dark', child: Text('Dark Mode')),
                                DropdownMenuItem(value: 'cartoon', child: Text('Cartoon / Game')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _mapTheme = val);
                                  _updateDisplaySettings();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: const Text('Cloud Animations'),
                        subtitle: const Text('Turn off for better performance'),
                        value: _cloudAnimation,
                        onChanged: (val) {
                          setState(() => _cloudAnimation = val);
                          _updateDisplaySettings();
                        },
                        secondary: const Icon(Icons.cloud_outlined),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                _buildSectionHeader('Localization Options'),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Distance Units',
                              style: TextStyle(fontSize: 16),
                            ),
                            SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(value: 'km', label: Text('km')),
                                ButtonSegment(value: 'miles', label: Text('mi')),
                              ],
                              selected: {_units},
                              onSelectionChanged: (Set<String> newSelection) {
                                setState(() => _units = newSelection.first);
                                _updateDisplaySettings();
                              },
                              style: ButtonStyle(
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Language',
                              style: TextStyle(fontSize: 16),
                            ),
                            DropdownButton<String>(
                              value: _language,
                              underline: const SizedBox(),
                              items: _availableLanguages.map((String lang) {
                                return DropdownMenuItem(
                                  value: lang,
                                  child: Text(lang),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _language = val);
                                  _updateDisplaySettings();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
