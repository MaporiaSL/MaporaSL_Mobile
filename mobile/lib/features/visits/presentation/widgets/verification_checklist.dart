import 'package:flutter/material.dart';

enum StepStatus { pending, checking, passed, failed }

class VerificationStep {
  final String label;
  final IconData icon;
  StepStatus status;

  VerificationStep({
    required this.label,
    required this.icon,
    this.status = StepStatus.pending,
  });
}

class VerificationChecklist extends StatelessWidget {
  final List<VerificationStep> steps;
  final int currentStepIndex;

  const VerificationChecklist({
    super.key,
    required this.steps,
    required this.currentStepIndex,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        final step = steps[index];
        final isActive = index == currentStepIndex;
        final isDone = step.status == StepStatus.passed;
        final isFailed = step.status == StepStatus.failed;
        final isChecking = step.status == StepStatus.checking;

        Color iconColor = Colors.grey;
        if (isDone) iconColor = Colors.green;
        if (isFailed) iconColor = Colors.red;
        if (isActive || isChecking) iconColor = Colors.blue;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: isChecking 
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
                    )
                  : Icon(
                      isDone ? Icons.check_circle : (isFailed ? Icons.error : step.icon),
                      size: 18,
                      color: iconColor,
                    ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  step.label,
                  style: TextStyle(
                    color: isActive || isChecking ? Colors.black87 : Colors.grey,
                    fontWeight: isActive || isChecking ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
              if (isDone)
                const Icon(Icons.check, color: Colors.green, size: 16),
              if (isFailed)
                const Icon(Icons.close, color: Colors.red, size: 16),
            ],
          ),
        );
      },
    );
  }
}

