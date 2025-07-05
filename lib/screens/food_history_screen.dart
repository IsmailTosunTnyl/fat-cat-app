// lib/screens/food_history_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/daily_food_summary.dart';
import '../models/monthly_food_summary.dart';
import '../services/firebase_service.dart';

class FoodHistoryScreen extends StatefulWidget {
  const FoodHistoryScreen({super.key});

  @override
  State<FoodHistoryScreen> createState() => _FoodHistoryScreenState();
}

class _FoodHistoryScreenState extends State<FoodHistoryScreen> {
  final _firebaseService = FirebaseService();
  late Future<List<DailyFoodSummary>> _dailySummaryFuture;
  late Future<List<MonthlyFoodSummary>> _monthlySummaryFuture;

  final List<Color> _dailyColors = [
    const Color(0xFF2196F3),
    const Color(0xFF9C27B0),
  ];

  @override
  void initState() {
    super.initState();
    _dailySummaryFuture = _firebaseService.getDailyFoodSummary();
    _monthlySummaryFuture = _firebaseService.getMonthlyFoodSummary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mama Geçmişi')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Günlük Tüketim',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildDailyChart(),
              const SizedBox(height: 32),
              const Text(
                'Aylık Tüketim',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildMonthlyChart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  Widget _buildDailyChart() {
    return FutureBuilder<List<DailyFoodSummary>>(
      future: _dailySummaryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}'));
        }

        final summaries = snapshot.data!;
        return Column(
          children: [
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 150,
                  groupsSpace: 12,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String value = rodIndex == 0
                            ? '${rod.toY.toInt()}g'
                            : '${(rod.toY / 25).toInt()} adet';
                        return BarTooltipItem(
                          value,
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  barGroups: summaries.asMap().entries.map((entry) {
                    final index = entry.key;
                    final summary = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barsSpace: 2,
                      barRods: [
                        BarChartRodData(
                          toY: summary.totalDryFoodGrams > 150 ? 150 : summary.totalDryFoodGrams,
                          width: 16,
                          color: _dailyColors[0],
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                          borderSide: summary.isOverLimit
                              ? const BorderSide(color: Colors.red, width: 2)
                              : BorderSide.none,
                        ),
                        BarChartRodData(
                          toY: summary.totalWetFoodCount * 25,
                          width: 16,
                          color: _dailyColors[0].withOpacity(0.3),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                          borderSide: summary.isOverLimit
                              ? const BorderSide(color: Colors.red, width: 2)
                              : BorderSide.none,
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}g',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                        reservedSize: 32,
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 25,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${(value / 25).toInt()} adet',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                        reservedSize: 32,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final date = summaries[value.toInt()].dateTime;
                          return Text(
                            '${date.day}/${date.month}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 30,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Kuru Mama', _dailyColors[0]),
                const SizedBox(width: 16),
                _buildLegendItem(
                  'Yaş Mama',
                  _dailyColors[0].withOpacity(0.3),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMonthlyChart() {
    return FutureBuilder<List<MonthlyFoodSummary>>(
      future: _monthlySummaryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}'));
        }

        final summaries = snapshot.data!;
        return Column(
          children: [
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceBetween,
                  maxY: 750,
                  groupsSpace: 32,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String value = rodIndex == 0
                            ? '${(rod.toY * (2000/750)).toInt()}g'
                            : '${(rod.toY / 25).toInt()} adet';
                        return BarTooltipItem(
                          value,
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  barGroups: summaries.asMap().entries.map((entry) {
                    final index = entry.key;
                    final summary = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barsSpace: 4,
                      barRods: [
                        BarChartRodData(
                          toY: summary.monthlyDryGrams * (750/2000),
                          width: 20,
                          color: _dailyColors[0],
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                        BarChartRodData(
                          toY: (summary.monthlyWetCount * 25.0).clamp(0.0, 750.0),
                          width: 20,
                          color: _dailyColors[0].withOpacity(0.3),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 150,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              '${(value * (2000/750)).toInt()}g',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                        reservedSize: 32,
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 125,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) {
                          if (value > 750) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              '${(value / 25).toInt()} adet',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final date = summaries[value.toInt()].month;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${date.month}/${date.year}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 150,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Kuru Mama', _dailyColors[0]),
                const SizedBox(width: 16),
                _buildLegendItem(
                  'Yaş Mama',
                  _dailyColors[0].withOpacity(0.3),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
