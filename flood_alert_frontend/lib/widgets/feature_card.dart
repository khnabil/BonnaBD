import 'package:flutter/material.dart';
import '../constants.dart';

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String text;

  const FeatureCard({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 110,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Colors.teal.withOpacity(0.2),
            child: Icon(icon, color: Colors.tealAccent, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: kTextColor, fontSize: 11),
          ),
        ],
      ),
    );
  }
}