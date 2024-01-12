import 'package:flutter/material.dart';

Widget overviewCard(String title) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.wb_sunny),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.opacity),
              SizedBox(width: 8),
              Text('Humidity'),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.waves),
              SizedBox(width: 8),
              Text('Moisture'),
            ],
          ),
        ],
      ),
    ),
  );
}