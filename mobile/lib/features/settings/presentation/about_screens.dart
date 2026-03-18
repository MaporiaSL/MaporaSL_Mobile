import 'package:flutter/material.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/services/auth_service.dart';

// ── Terms & Privacy ──────────────────────────────────────────────────────────

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
              'By using Maporia, you agree to our terms and conditions. '
              'You must use the app in accordance with applicable laws and regulations. '
              'We reserve the right to terminate accounts that violate our policies.',
            ),
            SizedBox(height: 24),
            Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'We value your privacy. We collect only the data necessary to deliver '
              'the Maporia experience — such as your location during check-ins and your '
              'profile information. We never sell your data to third parties. '
              'You may request full data deletion at any time via Settings → Privacy.',
            ),
          ],
        ),
      ),
    );
  }
}

// ── Help / FAQ ───────────────────────────────────────────────────────────────

class HelpFAQScreen extends StatelessWidget {
  const HelpFAQScreen({super.key});

  static const _faqs = [
    (
      'What is Maporia?',
      'Maporia is your ultimate travel companion for exploring Sri Lanka. Unlock districts, '
          'collect achievements, and document your journeys.',
    ),
    (
      'How do I check in at a place?',
      'Navigate to the Map screen, tap on any place marker, and press the "Check In" button '
          'when you are physically at that location.',
    ),
    (
      'How is my location used?',
      'Your GPS location is used only during active check-ins to verify you are at the place. '
          'We never track your location in the background.',
    ),
    (
      'How do I contact support?',
      'Use the "Send Feedback" option in Settings → About, or email us at support@maporia.com.',
    ),
    (
      'Is Maporia free?',
      'Yes, the core features of Maporia are free to use.',
    ),
    (
      'Can I delete my account?',
      'Yes. Go to Settings → Privacy & Location → Data Deletion Request to permanently delete your account and all associated data.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help / FAQ'),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: _faqs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final faq = _faqs[index];
          return Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ExpansionTile(
              title: Text(
                faq.$1,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              childrenPadding:
                  const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [Text(faq.$2)],
            ),
          );
        },
      ),
    );
  }
}

// ── Send Feedback ────────────────────────────────────────────────────────────

class SendFeedbackScreen extends StatefulWidget {
  const SendFeedbackScreen({super.key});

  @override
  State<SendFeedbackScreen> createState() => _SendFeedbackScreenState();
}

class _SendFeedbackScreenState extends State<SendFeedbackScreen> {
  final _apiClient = ApiClient();
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  int _rating = 0; // 0 = no rating selected
  bool _isSubmitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _authService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to send feedback.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _apiClient.post(
        '/api/feedback',
        data: {
          'subject': _subjectController.text.trim(),
          'message': _messageController.text.trim(),
          if (_rating > 0) 'rating': _rating,
        },
      );

      if (mounted) setState(() => _submitted = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send feedback: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildStarRating() {
    return Row(
      children: List.generate(5, (index) {
        final star = index + 1;
        return IconButton(
          icon: Icon(
            star <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
            color: Colors.amber,
            size: 32,
          ),
          onPressed: () => setState(() => _rating = star),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Feedback'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: _submitted ? _buildSuccessState() : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildSuccessState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        const Icon(Icons.check_circle_outline,
            size: 80, color: Colors.green),
        const SizedBox(height: 24),
        const Text(
          'Thank you for your feedback!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Your response has been recorded. We appreciate you helping us improve Maporia.',
          style: TextStyle(fontSize: 15, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Back to Settings'),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'We\'d love to hear from you',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Your feedback helps us make Maporia better for everyone.',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 28),

          // Subject field
          TextFormField(
            controller: _subjectController,
            maxLength: 200,
            decoration: InputDecoration(
              labelText: 'Subject',
              hintText: 'e.g. Bug report, Feature request',
              prefixIcon: const Icon(Icons.title),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Subject is required' : null,
          ),
          const SizedBox(height: 16),

          // Message field
          TextFormField(
            controller: _messageController,
            maxLines: 5,
            maxLength: 2000,
            decoration: InputDecoration(
              labelText: 'Message',
              hintText: 'Describe your feedback in detail...',
              alignLabelWithHint: true,
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 72),
                child: Icon(Icons.message_outlined),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Message is required' : null,
          ),
          const SizedBox(height: 16),

          // Star rating (optional)
          const Text(
            'Rate your experience (optional)',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          _buildStarRating(),

          const SizedBox(height: 32),

          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _handleSubmit,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send_rounded),
              label: const Text('Submit Feedback',
                  style: TextStyle(fontSize: 15)),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
