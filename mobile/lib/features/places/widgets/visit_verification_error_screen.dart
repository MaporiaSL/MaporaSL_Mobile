import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../data/models/place_visit.dart';

/// Detailed error screen showing which validation checks failed
class VisitVerificationErrorScreen extends StatelessWidget {
  final PlaceVisitValidation validation;
  final String placeName;
  final double userLatitude;
  final double userLongitude;
  final double placeLatitude;
  final double placeLongitude;
  final VoidCallback? onRetry;
  final VoidCallback? onCancel;

  const VisitVerificationErrorScreen({
    super.key,
    required this.validation,
    required this.placeName,
    required this.userLatitude,
    required this.userLongitude,
    required this.placeLatitude,
    required this.placeLongitude,
    this.onRetry,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Verification Failed'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onCancel ?? () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildErrorHeader(context),
            const SizedBox(height: 24),

            // Main Error Message
            _buildMainErrorCard(context),
            const SizedBox(height: 24),

            // Validation Checks Details
            Text(
              'Verification Checks',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildChecksList(context),
            const SizedBox(height: 24),

            // Coordinates Comparison
            _buildCoordinatesCard(context),
            const SizedBox(height: 24),

            // Troubleshooting Tips
            _buildTroubleshootingCard(context),
            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Visit Not Verified',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Location verification failed for $placeName',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainErrorCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Why did verification fail?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              validation.invalidReason ??
                  'Your location could not be verified. Please review the checks below.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textDark,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildSeverityIndicator(context),
        ],
      ),
    );
  }

  Widget _buildSeverityIndicator(BuildContext context) {
    final color = _getSeverityColor();
    final label = _getSeverityLabel();

    return Row(
      children: [
        Text(
          'Severity: ',
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '(${validation.flagSeverity}/5)',
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildChecksList(BuildContext context) {
    final checks = [
      ValidationCheck(
        title: 'GPS Accuracy',
        isPassed: validation.gpsAccuracyValid,
        description: validation.gpsAccuracyValid
            ? 'Your GPS accuracy is within acceptable range'
            : 'GPS accuracy is too low. Required: <30m',
        icon: Icons.gps_fixed,
      ),
      ValidationCheck(
        title: 'Location Distance',
        isPassed: validation.geoFencingValid,
        description: validation.geoFencingValid
            ? 'You are within range of the place'
            : 'You are too far from the place. Required: <200m',
        icon: Icons.pin_drop,
      ),
      ValidationCheck(
        title: 'Device Heading',
        isPassed: validation.headingValid,
        description: validation.headingValid
            ? 'You are facing towards the place'
            : 'Face towards the place for verification',
        icon: Icons.explore,
      ),
      ValidationCheck(
        title: 'Photo Location',
        isPassed: validation.photoExifValid,
        description: validation.photoExifValid
            ? 'Photo location data matches'
            : 'Photo was taken at a different location',
        icon: Icons.photo_camera,
      ),
      ValidationCheck(
        title: 'Device Security',
        isPassed: !validation.deviceSignatureSuspicious,
        description: validation.deviceSignatureSuspicious
            ? '⚠️ Location spoofing detected. Disable mock location apps'
            : 'Device integrity verified',
        icon: Icons.security,
        isCritical: validation.deviceSignatureSuspicious,
      ),
      ValidationCheck(
        title: 'Rate Limit',
        isPassed: !validation.beingThrottled,
        description: validation.beingThrottled
            ? 'You visited this place recently. Wait before trying again'
            : 'No rate limit issues',
        icon: Icons.access_time,
      ),
      ValidationCheck(
        title: 'Travel Speed',
        isPassed: validation.speedValid,
        description: validation.speedValid
            ? 'Travel speed is reasonable'
            : '⚠️ Impossible travel speed detected',
        icon: Icons.speed,
        isCritical: !validation.speedValid,
      ),
    ];

    return Column(
      children: checks
          .map(
            (check) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildCheckItem(context, check),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCheckItem(BuildContext context, ValidationCheck check) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: check.isPassed
            ? Colors.green.withOpacity(0.05)
            : Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: check.isPassed
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: check.isPassed
                  ? Colors.green.withOpacity(0.2)
                  : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              check.icon,
              color: check.isPassed ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        check.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(
                      check.isPassed ? Icons.check_circle : Icons.cancel,
                      color: check.isPassed ? Colors.green : Colors.red,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  check.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                    height: 1.4,
                  ),
                ),
                if (check.isCritical && !check.isPassed) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'CRITICAL',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoordinatesCard(BuildContext context) {
    // Calculate distance between user and place
    final distance = _calculateDistance(
      userLatitude,
      userLongitude,
      placeLatitude,
      placeLongitude,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location Details',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildCoordinateRow(
            context,
            'Your Location',
            userLatitude,
            userLongitude,
            Icons.my_location,
            Colors.blue,
          ),
          const SizedBox(height: 8),
          _buildCoordinateRow(
            context,
            'Place Location',
            placeLatitude,
            placeLongitude,
            Icons.location_on,
            Colors.red,
          ),
          const Divider(height: 24),
          Row(
            children: [
              Icon(Icons.straighten, color: AppColors.textMuted, size: 20),
              const SizedBox(width: 8),
              Text(
                'Distance: ',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
              Text(
                distance < 1000
                    ? '${distance.toStringAsFixed(0)} meters'
                    : '${(distance / 1000).toStringAsFixed(2)} km',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: distance <= 200 ? Colors.green : Colors.red,
                ),
              ),
              if (distance > 200) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'TOO FAR',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoordinateRow(
    BuildContext context,
    String label,
    double lat,
    double lng,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
              ),
              Text(
                '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTroubleshootingCard(BuildContext context) {
    final tips = _getTroubleshootingTips();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.blue, size: 24),
              const SizedBox(width: 12),
              Text(
                'How to Fix',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tips
              .asMap()
              .entries
              .map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.textDark,
                                height: 1.5,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onCancel ?? () => Navigator.pop(context),
            child: const Text('Cancel'),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
          ),
        ),
      ],
    );
  }

  Color _getSeverityColor() {
    switch (validation.flagSeverity) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.yellow.shade700;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.deepOrange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getSeverityLabel() {
    switch (validation.flagSeverity) {
      case 1:
        return 'Low';
      case 2:
        return 'Minor';
      case 3:
        return 'Moderate';
      case 4:
        return 'High';
      case 5:
        return 'Critical';
      default:
        return 'Unknown';
    }
  }

  List<String> _getTroubleshootingTips() {
    final tips = <String>[];

    if (!validation.gpsAccuracyValid) {
      tips.add(
        'Move to an open area away from tall buildings for better GPS signal',
      );
      tips.add('Wait 30-60 seconds for GPS to stabilize');
    }

    if (!validation.geoFencingValid) {
      tips.add('Walk closer to the place (within 200 meters)');
      tips.add('Make sure you\'re at the correct location');
    }

    if (!validation.headingValid) {
      tips.add('Point your device towards the place');
      tips.add('Calibrate your compass by moving device in figure-8 pattern');
    }

    if (validation.deviceSignatureSuspicious) {
      tips.add('⚠️ Disable any mock location or GPS spoofing apps');
      tips.add('⚠️ Check Developer Options for mock location settings');
      tips.add('Restart your device if problems persist');
    }

    if (validation.beingThrottled) {
      tips.add('Wait at least 1 hour before visiting this place again');
    }

    if (!validation.speedValid) {
      tips.add('Your previous visit was too recent relative to distance');
      tips.add('Make sure you\'re not using location spoofing');
    }

    if (tips.isEmpty) {
      tips.add('Ensure you are physically present at the location');
      tips.add('Check your GPS is enabled and working properly');
      tips.add('Try again in a few moments');
    }

    return tips;
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371000; // Earth radius in meters
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a =
        _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(lat1)) *
            _cos(_toRadians(lat2)) *
            _sin(dLon / 2) *
            _sin(dLon / 2);
    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double degrees) => degrees * (3.141592653589793 / 180);
  double _sin(double x) => x - (x * x * x) / 6 + (x * x * x * x * x) / 120;
  double _cos(double x) => 1 - (x * x) / 2 + (x * x * x * x) / 24;
  double _sqrt(double x) {
    double guess = x / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  double _atan2(double y, double x) {
    if (x > 0) return _atan(y / x);
    if (x < 0 && y >= 0) return _atan(y / x) + 3.141592653589793;
    if (x < 0 && y < 0) return _atan(y / x) - 3.141592653589793;
    if (x == 0 && y > 0) return 3.141592653589793 / 2;
    if (x == 0 && y < 0) return -3.141592653589793 / 2;
    return 0;
  }

  double _atan(double x) {
    return x - (x * x * x) / 3 + (x * x * x * x * x) / 5;
  }
}

/// Validation check data class
class ValidationCheck {
  final String title;
  final bool isPassed;
  final String description;
  final IconData icon;
  final bool isCritical;

  ValidationCheck({
    required this.title,
    required this.isPassed,
    required this.description,
    required this.icon,
    this.isCritical = false,
  });
}
