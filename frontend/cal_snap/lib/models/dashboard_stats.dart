class DashboardStats {
  final int totalCalories;
  final int remainingCalories;
  final int proteinGrams;
  final int carbGrams;
  final int fatGrams;

  DashboardStats({
    required this.totalCalories,
    required this.remainingCalories,
    required this.proteinGrams,
    required this.carbGrams,
    required this.fatGrams,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalCalories: json['total_calories'] ?? 0,
      remainingCalories: json['remaining_calories'] ?? 2500,
      proteinGrams: json['protein_grams'] ?? 0,
      carbGrams: json['carb_grams'] ?? 0,
      fatGrams: json['fat_grams'] ?? 0,
    );
  }

  factory DashboardStats.empty() {
    return DashboardStats(
      totalCalories: 0,
      remainingCalories: 2500,
      proteinGrams: 0,
      carbGrams: 0,
      fatGrams: 0,
    );
  }
} 