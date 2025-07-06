import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/daily_food_summary.dart';
import '../models/food_entry.dart';
import '../models/monthly_food_summary.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addFoodEntry(FoodEntry entry) async {
    try {
      await _firestore.collection('food_entries').add({
        'date': entry.date,
        'dry_food_amount': entry.dryFoodAmount,
        'wet_food_count': entry.wetFoodCount,
      });
    } catch (e) {
      throw Exception('Firebase error: $e');
    }
  }

  Future<List<DailyFoodSummary>> getDailyFoodSummary() async {
    try {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));

      final QuerySnapshot snapshot = await _firestore
          .collection('food_entries')
          .where('date', isGreaterThanOrEqualTo: sevenDaysAgo)
          .orderBy('date', descending: true)
          .get();

      final Map<String, DailyFoodSummaryBuilder> summaryBuilders = {};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final date = (data['date'] as Timestamp).toDate();
        final dateKey = '${date.year}-${date.month}-${date.day}';

        if (!summaryBuilders.containsKey(dateKey)) {
          summaryBuilders[dateKey] = DailyFoodSummaryBuilder(
            dateTime: DateTime(date.year, date.month, date.day),
          );
        }

        summaryBuilders[dateKey]!.addEntry(
          data['dry_food_amount'].toDouble(),
          data['wet_food_count'],
        );
      }

      return summaryBuilders.values.map((builder) => builder.build()).toList()
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    } catch (e) {
      throw Exception('Firebase error: $e');
    }
  }

  Future<List<MonthlyFoodSummary>> getMonthlyFoodSummary() async {
    try {
      final now = DateTime.now();
      final twelveMonthsAgo = DateTime(now.year - 1, now.month + 1);

      final QuerySnapshot snapshot = await _firestore
          .collection('food_entries')
          .where('date', isGreaterThanOrEqualTo: twelveMonthsAgo)
          .orderBy('date', descending: true)
          .get();

      final Map<String, MonthlyFoodSummaryBuilder> summaryBuilders = {};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final date = (data['date'] as Timestamp).toDate();
        final monthKey = '${date.year}-${date.month}';

        if (!summaryBuilders.containsKey(monthKey)) {
          summaryBuilders[monthKey] = MonthlyFoodSummaryBuilder(
            month: DateTime(date.year, date.month),
          );
        }

        summaryBuilders[monthKey]!.addEntry(
          data['dry_food_amount'].toDouble(),
          data['wet_food_count'],
        );
      }

      return summaryBuilders.values.map((builder) => builder.build()).toList()
        ..sort((a, b) => b.month.compareTo(a.month));
    } catch (e) {
      throw Exception('Firebase error: $e');
    }
  }

  Future<DailyFoodSummary> getTodaySummary({DateTime? selectedDate}) async {
    try {
      final queryDate = selectedDate ?? DateTime.now();
      final startOfDay = DateTime(queryDate.year, queryDate.month, queryDate.day);
      final endOfDay = DateTime(queryDate.year, queryDate.month, queryDate.day, 23, 59, 59);

      final QuerySnapshot snapshot = await _firestore
          .collection('food_entries')
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThanOrEqualTo: endOfDay)
          .get();

      final summaryBuilder = DailyFoodSummaryBuilder(dateTime: startOfDay);

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        summaryBuilder.addEntry(
          data['dry_food_amount'].toDouble(),
          data['wet_food_count'] as int,
        );
      }

      return summaryBuilder.build();
    } catch (e) {
      throw Exception('Firebase error: $e');
    }
  }
}

class DailyFoodSummaryBuilder {
  final DateTime dateTime;
  double totalDryFoodGrams = 0;
  int totalWetFoodCount = 0;

  DailyFoodSummaryBuilder({required this.dateTime});

  void addEntry(double dryFood, int wetFood) {
    totalDryFoodGrams += dryFood;
    totalWetFoodCount += wetFood;
  }

  DailyFoodSummary build() {
    return DailyFoodSummary(
      dateTime: dateTime,
      totalDryFoodGrams: totalDryFoodGrams,
      totalWetFoodCount: totalWetFoodCount,
    );
  }
}

class MonthlyFoodSummaryBuilder {
  final DateTime month;
  double monthlyDryGrams = 0;
  int monthlyWetCount = 0;

  MonthlyFoodSummaryBuilder({required this.month});

  void addEntry(double dryFood, int wetFood) {
    monthlyDryGrams += dryFood;
    monthlyWetCount += wetFood;
  }

  MonthlyFoodSummary build() {
    return MonthlyFoodSummary(
      month: month,
      monthlyDryGrams: monthlyDryGrams,
      monthlyWetCount: monthlyWetCount,
    );
  }
}
