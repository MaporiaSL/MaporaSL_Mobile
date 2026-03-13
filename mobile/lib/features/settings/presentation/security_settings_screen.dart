import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/security_provider.dart';

class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  ConsumerState<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends ConsumerState<SecuritySettingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(securityProvider.notifier).fetchSessions());
  }

  @override
  Widget build(BuildContext context) {
    final securityState = ref.watch(securityProvider);
    final securityNotifier = ref.read(securityProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('App Protection'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.lock_outline, color: Colors.blueAccent),
              title: const Text('App Lock'),
              subtitle: const Text('Require PIN or Biometrics to open'),
              trailing: Switch(
                value: securityState.isAppLockEnabled,
                onChanged: (value) => securityNotifier.toggleAppLock(value),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          _buildSectionHeader('Active Sessions'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                if (securityState.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  )
                else if (securityState.activeSessions.isEmpty)
                  const ListTile(title: Text('No active sessions found'))
                else
                  ...securityState.activeSessions.map((session) => ListTile(
                    leading: const Icon(Icons.devices, color: Colors.teal),
                    title: Text(session['device'] ?? 'Unknown Device'),
                    subtitle: Text('IP: ${session['ip']} • ${session['lastUsed']}'),
                    trailing: const Icon(Icons.info_outline, size: 16),
                  )),
                const Divider(height: 1),
                TextButton.icon(
                  onPressed: () => _showLogoutConfirmation(context, securityNotifier),
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  label: const Text('Logout all other devices', style: TextStyle(color: Colors.redAccent)),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          _buildSectionHeader('Two-Factor Authentication'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.security, color: Colors.orangeAccent),
              title: const Text('2FA (Authenticator App)'),
              subtitle: Text(securityState.is2FAEnabled ? 'Enabled' : 'Disabled'),
              trailing: ElevatedButton(
                onPressed: () => _handle2FAToggle(context, securityState, securityNotifier),
                style: ElevatedButton.styleFrom(
                  backgroundColor: securityState.is2FAEnabled ? Colors.red.shade50 : Colors.blue.shade50,
                  foregroundColor: securityState.is2FAEnabled ? Colors.red : Colors.blue,
                  elevation: 0,
                ),
                child: Text(securityState.is2FAEnabled ? 'Disable' : 'Set Up'),
              ),
            ),
          ),
        ],
      ),
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

  void _showLogoutConfirmation(BuildContext context, SecurityNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout all devices?'),
        content: const Text('This will log you out from all other devices where you are currently signed in.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              notifier.logoutAllDevices();
              Navigator.pop(context);
            },
            child: const Text('Logout All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _handle2FAToggle(BuildContext context, SecurityState state, SecurityNotifier notifier) async {
    if (state.is2FAEnabled) {
      notifier.disable2FA();
    } else {
      final setup = await notifier.setup2FA();
      if (setup != null && mounted) {
        _show2FASetupDialog(context, setup, notifier);
      }
    }
  }

  void _show2FASetupDialog(BuildContext context, Map<String, dynamic> setup, SecurityNotifier notifier) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set up 2FA'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Scan this QR code with your authenticator app:'),
              const SizedBox(height: 16),
              Image.network(setup['qrCode'], height: 150, width: 150),
              const SizedBox(height: 16),
              const Text('Or enter this code manually:'),
              SelectableText(setup['secret'], style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Enter 6-digit code',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final success = await notifier.verifyAndEnable2FA(controller.text);
              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('2FA enabled successfully!')),
                );
              }
            },
            child: const Text('Verify & Enable'),
          ),
        ],
      ),
    );
  }
}
