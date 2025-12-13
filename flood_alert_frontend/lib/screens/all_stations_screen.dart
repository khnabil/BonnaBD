import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/station.dart';

class AllStationsScreen extends StatelessWidget {
  final List<Station> stations;

  const AllStationsScreen({super.key, required this.stations});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text("All Water Stations"),
        backgroundColor: kCardColor,
      ),
      body: ListView.builder(
        itemCount: stations.length,
        itemBuilder: (context, index) {
          final station = stations[index];
          final isDanger = station.currentLevel >= station.dangerLevel;
          
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kCardColor,
              borderRadius: BorderRadius.circular(12),
              border: isDanger ? Border.all(color: Colors.red, width: 1) : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(station.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(station.river, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                Text(
                  "${station.currentLevel.toStringAsFixed(2)} m",
                  style: TextStyle(
                    color: isDanger ? Colors.redAccent : Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}