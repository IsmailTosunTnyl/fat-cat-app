// lib/models/monthly_food_summary.dart
class MonthlyFoodSummary {
  final DateTime month;
  final double monthlyDryGrams;
  final int monthlyWetCount;

  MonthlyFoodSummary({
    required this.month,
    required this.monthlyDryGrams,
    required this.monthlyWetCount,
  });

  factory MonthlyFoodSummary.fromJson(Map<String, dynamic> json) {
    return MonthlyFoodSummary(
      month: DateTime.parse('${json['month']}-01'),
      monthlyDryGrams: json['monthly_dry_grams'].toDouble(),
      monthlyWetCount: json['monthly_wet_count'],
    );
  }
}