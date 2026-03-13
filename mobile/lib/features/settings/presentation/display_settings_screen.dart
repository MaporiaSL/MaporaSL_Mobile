import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/providers/accessibility_provider.dart';

class DisplaySettingsScreen extends ConsumerStatefulWidget {
  const DisplaySettingsScreen({super.key});

  @override
  ConsumerState<DisplaySettingsScreen> createState() => _DisplaySettingsScreenState();
}

class _DisplaySettingsScreenState extends ConsumerState<DisplaySettingsScreen> {
  final _apiClient = ApiClient();
  final _authService = AuthService();

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
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateDisplaySettings(String mapTheme) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      await _apiClient.put(
        '/api/users/${user.uid}/display',
        data: {
          'mapTheme': mapTheme,
          'cloudAnimation': _cloudAnimation,
          'units': _units,
          'language': _language,
        },
      );
    } catch (e) {
      if (mounted) {
        String errMsg = 'Failed to update map settings: $e';
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
                              value: ref.watch(themeProvider),
                              underline: const SizedBox(),
                              items: const [
                                DropdownMenuItem(value: 'light', child: Text('Light Mode')),
                                DropdownMenuItem(value: 'dark', child: Text('Dark Mode')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  ref.read(themeProvider.notifier).setTheme(val);
                                  _updateDisplaySettings(val);
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
                        value: ref.watch(accessibilityProvider).reduceMotion ? false : _cloudAnimation,
                        onChanged: ref.watch(accessibilityProvider).reduceMotion ? null : (val) {
                          setState(() => _cloudAnimation = val);
                          _updateDisplaySettings(ref.read(themeProvider));
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
                                _updateDisplaySettings(ref.read(themeProvider));
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
                                  _updateDisplaySettings(ref.read(themeProvider));
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
