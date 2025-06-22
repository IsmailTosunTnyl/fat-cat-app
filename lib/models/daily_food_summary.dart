// lib/models/daily_food_summary.dart
class DailyFoodSummary {
  final DateTime dateTime;
  final double totalDryFoodGrams;
  final int totalWetFoodCount;
  final bool isOverLimit;

  DailyFoodSummary({
    required this.dateTime,
    required this.totalDryFoodGrams,
    required this.totalWetFoodCount,
  }) : isOverLimit = totalDryFoodGrams > 60 || (totalDryFoodGrams >= 50 && totalWetFoodCount >= 1);

  factory DailyFoodSummary.fromJson(Map<String, dynamic> json) {
    return DailyFoodSummary(
      dateTime: DateTime.parse(json['day']),
      totalDryFoodGrams: json['total_dry_food_grams'].toDouble(),
      totalWetFoodCount: json['total_wet_food_count'],
    );
  }
}