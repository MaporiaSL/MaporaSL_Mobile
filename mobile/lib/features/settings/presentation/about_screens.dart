import 'package:flutter/material.dart';

class TermsPrivacyScreen extends StatelessWidget {
  const TermsPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Privacy'),
        centerTitle: true,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Service',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Placeholder for Terms of Service content. By using Maporia, you agree to our terms and conditions...',
            ),
            SizedBox(height: 24),
            Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Placeholder for Privacy Policy content. Your data privacy is important to us. Here is how we handle your data...',
            ),
          ],
        ),
      ),
    );
  }
}

class HelpFAQScreen extends StatelessWidget {
  const HelpFAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help / FAQ'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          ExpansionTile(
            title: Text('What is Maporia?'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Maporia is your ultimate travel companion for exploring Sri Lanka.'),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('How do I contact support?'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('You can use the "Send Feedback" option in settings or email us at support@maporia.com.'),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('Is Maporia free?'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Yes, the core features of Maporia are free to use.'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
