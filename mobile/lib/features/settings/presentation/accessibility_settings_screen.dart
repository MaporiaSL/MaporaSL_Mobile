import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/accessibility_provider.dart';

class AccessibilitySettingsScreen extends ConsumerStatefulWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  ConsumerState<AccessibilitySettingsScreen> createState() => _AccessibilitySettingsScreenState();
}

class _AccessibilitySettingsScreenState extends ConsumerState<AccessibilitySettingsScreen> {
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(accessibilityProvider);
    final notifier = ref.read(accessibilityProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accessibility'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('Visual Preferences'),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.format_size, size: 20),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Font Size Adjustment',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Text('${(settings.fontSize * 100).toInt()}%'),
                    ],
                  ),
                ),
                Slider(
                  value: settings.fontSize,
                  min: 0.8,
                  max: 1.5,
                  divisions: 7,
                  onChanged: (value) {
                    notifier.setFontSize(value);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('High Contrast Mode'),
                  subtitle: const Text('Improve text and element visibility'),
                  value: settings.highContrast,
                  onChanged: (val) {
                    notifier.setHighContrast(val);
                  },
                  secondary: const Icon(Icons.contrast),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          _buildSectionHeader('Motion & Interaction'),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              title: const Text('Reduce Motion'),
              subtitle: const Text('Minimize UI animations and map transitions'),
              value: settings.reduceMotion,
              onChanged: (val) {
                notifier.setReduceMotion(val);
              },
              secondary: const Icon(Icons.animation),
            ),
          ),
          
          const SizedBox(height: 24),

          _buildSectionHeader('Assistive Technologies'),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: const ListTile(
              leading: Icon(Icons.record_voice_over),
              title: Text('Screen Reader Support'),
              subtitle: Text('Maporia is optimized for TalkBack and VoiceOver navigation. Map exploration uses semantic readouts for regions and districts.'),
              isThreeLine: true,
            ),
          ),
        ],
      ),
    );
  }
}
