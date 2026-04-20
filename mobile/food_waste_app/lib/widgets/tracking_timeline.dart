import 'package:flutter/material.dart';
import 'package:food_waste_app/data/models/tracking_step.dart';

class TrackingTimeline extends StatelessWidget {
  final List<TrackingStep> steps;

  const TrackingTimeline({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: steps.map((step) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Icon(
                  step.isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: step.isCompleted ? Colors.green : Colors.grey,
                ),
                Container(
                  width: 2,
                  height: 40,
                  color: Colors.grey.shade300,
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(step.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                    Text(step.description,
                        style: const TextStyle(color: Colors.grey)),
                    if (step.completedAt != null)
                      Text("Tamamlandı: ${step.completedAt}",
                          style: const TextStyle(
                              fontSize: 12, color: Colors.green)),
                  ],
                ),
              ),
            )
          ],
        );
      }).toList(),
    );
  }
}