import 'package:flutter/material.dart';
import '../constants.dart';
import '../services/api_service.dart';
import '../models/campaign.dart';

class DonateScreen extends StatefulWidget {
  const DonateScreen({super.key});

  @override
  State<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends State<DonateScreen> {
  late Future<List<Campaign>> futureCampaigns;

  @override
  void initState() {
    super.initState();
    futureCampaigns = ApiService.fetchCampaigns();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor, // Keeping your dark theme
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text("Active Relief Funds",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
      ),
      body: FutureBuilder<List<Campaign>>(
        future: futureCampaigns,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: kPrimaryCyan));
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No active campaigns right now.", style: TextStyle(color: Colors.white)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return _buildCampaignCard(snapshot.data![index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildCampaignCard(Campaign campaign) {
    // Calculate progress for the bar
    double progress = campaign.percentFunded;
    int percentText = (progress * 100).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        color: kCardColor, // Dark card background
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. IMAGE SECTION (With "Urgent" Badge)
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  // Using a placeholder flood image since backend doesn't have images yet
                  "https://images.unsplash.com/photo-1547623641-82f92526b095?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80",
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => 
                      Container(height: 180, color: Colors.grey[800], child: const Icon(Icons.image, color: Colors.white)),
                ),
              ),
              Positioned(
                top: 15,
                right: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text("URGENT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. TITLE & ORGANIZER
                Text(
                  campaign.title,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.verified, color: kPrimaryCyan, size: 16),
                    const SizedBox(width: 5),
                    Text(
                      "Verified NGO Campaign", // You can fetch real NGO name later
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 3. FINANCIAL STATS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "\$${campaign.raisedAmount.toStringAsFixed(0)}",
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "of \$${campaign.targetAmount.toStringAsFixed(0)} goal",
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // 4. PROGRESS BAR
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey[800],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)), // Gold/Yellow color
                  ),
                ),

                const SizedBox(height: 10),

                // 5. PERCENTAGE & DONORS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("$percentText% funded", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                    Text("120 donors", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                  ],
                ),

                const SizedBox(height: 25),

                // 6. DONATE BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // Add donation logic here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700), // The bright yellow from your design
                      foregroundColor: Colors.black, // Black text on yellow button
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                    ),
                    child: const Text("Donate Now", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}