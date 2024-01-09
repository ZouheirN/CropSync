import 'package:flutter/material.dart';

Widget overviewCard() {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.wb_sunny),
              SizedBox(width: 8),
              Text('Temperature'),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.opacity),
              SizedBox(width: 8),
              Text('Humidity'),
            ],
          ),
          SizedBox(height: 16),
          Row(
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