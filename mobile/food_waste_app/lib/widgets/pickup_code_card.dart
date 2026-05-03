import 'package:flutter/material.dart';

class PickupCodeCard extends StatelessWidget {
  final String code;

  const PickupCodeCard({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Teslim Kodu",
                  style: TextStyle(fontSize: 10, color: Colors.grey)),
              const SizedBox(height: 8),
              Text(
                code,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
          const Icon(Icons.qr_code, color: Colors.green, size: 30),
        ],
      ),
    );
  }
}

