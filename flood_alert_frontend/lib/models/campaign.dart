class Campaign {
  final int id;
  final String title;
  final String description;
  final double targetAmount;
  final double raisedAmount;
  final int ngoId;

  Campaign({
    required this.id,
    required this.title,
    required this.description,
    required this.targetAmount,
    required this.raisedAmount,
    required this.ngoId,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'] ?? 0,
      title: json['title'] ?? "Untitled Campaign",
      description: json['description'] ?? "No description provided.",
      targetAmount: (json['target_amount'] ?? 0).toDouble(),
      raisedAmount: (json['raised_amount'] ?? 0).toDouble(),
      ngoId: json['ngo_id'] ?? 0,
    );
  }

  // Helper to calculate percentage for the progress bar
  double get percentFunded {
    if (targetAmount == 0) return 0.0;
    double percent = raisedAmount / targetAmount;
    return percent > 1.0 ? 1.0 : percent; // Cap at 100%
  }
}