import 'package:flutter/material.dart';

class StoreLocationCard extends StatelessWidget {
  final String name;
  final String address;

  const StoreLocationCard({
    super.key,
    required this.name,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text("$name\n$address",
            textAlign: TextAlign.center),
      ),
    );
  }
}