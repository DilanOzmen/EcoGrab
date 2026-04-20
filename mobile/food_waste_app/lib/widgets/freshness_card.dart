import 'package:flutter/material.dart';

class FreshnessCard extends StatelessWidget {
  final int percent;

  const FreshnessCard({super.key, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Tazelik Durumu",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: percent / 100,
            color: Colors.green,
          ),
          const SizedBox(height: 6),
          Text("%$percent optimal"),
        ],
      ),
    );
  }
}