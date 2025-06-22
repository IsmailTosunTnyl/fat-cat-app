// lib/models/food_entry.dart
class FoodEntry {
  final DateTime date;
  final double dryFoodAmount;
  final int wetFoodCount;

  FoodEntry({
    required this.date,
    required this.dryFoodAmount,
    required this.wetFoodCount,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'dryFoodAmount': dryFoodAmount,
    'wetFoodCount': wetFoodCount,
  };

  factory FoodEntry.fromJson(Map<String, dynamic> json) {
    return FoodEntry(
      date: DateTime.parse(json['date']),
      dryFoodAmount: json['dryFoodAmount'].toDouble(),
      wetFoodCount: json['wetFoodCount'] as int,
    );
  }
}