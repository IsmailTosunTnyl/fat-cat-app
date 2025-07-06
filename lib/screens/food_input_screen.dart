import 'package:flutter/material.dart';
import '../models/food_entry.dart';
import '../models/daily_food_summary.dart';
import '../services/firebase_service.dart';

class FoodInputScreen extends StatefulWidget {
  const FoodInputScreen({super.key});

  @override
  State<FoodInputScreen> createState() => _FoodInputScreenState();
}

class _FoodInputScreenState extends State<FoodInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dryFoodController = TextEditingController();
  final _wetFoodController = TextEditingController(text: "0");
  final _firebaseService = FirebaseService();
  DateTime _selectedDate = DateTime.now();

  DailyFoodSummary? _todaySummary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodaySummary();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now.subtract(const Duration(days: 7)),
      lastDate: now,
      locale: const Locale('tr', 'TR'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadTodaySummary();
    }
  }

  Future<void> _loadTodaySummary() async {
    setState(() => _isLoading = true);
    try {
      final summary = await _firebaseService.getTodaySummary(selectedDate: _selectedDate);
      setState(() {
        _todaySummary = summary;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veri yüklenirken hata: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Widget _buildSummaryCard() {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final summary = _todaySummary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Bugünkü Toplam:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Kuru Mama: ${summary?.totalDryFoodGrams.toStringAsFixed(1)} gram',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              'Yaş Mama: ${summary?.totalWetFoodCount} adet',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (summary?.isOverLimit == true) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Günlük mama limiti aşıldı!',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Günlük Mama Girişi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTodaySummary,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildSummaryCard(),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    trailing: TextButton(
                      onPressed: () => _selectDate(context),
                      child: const Text('Tarih Seç'),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _dryFoodController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Kuru Mama Miktarı (gram)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.pets),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen miktar giriniz';
                    }
                    if (double.tryParse(value) == null || double.parse(value) < 0) {
                      return 'Geçerli bir miktar giriniz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _wetFoodController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Yaş Mama (Adet)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.food_bank),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen adet giriniz';
                          }
                          if (int.tryParse(value) == null || int.parse(value) < 0) {
                            return 'Geçerli bir adet giriniz';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      children: [
                        IconButton(
                          onPressed: () {
                            int current = int.tryParse(_wetFoodController.text) ?? 0;
                            _wetFoodController.text = (current + 1).toString();
                          },
                          icon: const Icon(Icons.add_circle),
                        ),
                        IconButton(
                          onPressed: () {
                            int current = int.tryParse(_wetFoodController.text) ?? 0;
                            if (current > 0) {
                              _wetFoodController.text = (current - 1).toString();
                            }
                          },
                          icon: const Icon(Icons.remove_circle),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _submitFoodEntry,
                  icon: const Icon(Icons.save),
                  label: const Text('Kaydet'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitFoodEntry() async {
    if (_formKey.currentState!.validate()) {
      final dryAmount = double.parse(_dryFoodController.value.text);
      final wetCount = int.parse(_wetFoodController.value.text);

      final entry = FoodEntry(
        date: _selectedDate,
        dryFoodAmount: dryAmount,
        wetFoodCount: wetCount,
      );

      try {
        await _firebaseService.addFoodEntry(entry);
        await _loadTodaySummary();
        setState(() {
          _dryFoodController.clear();
          _wetFoodController.text = "0";
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mama kaydı başarıyla eklendi')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _dryFoodController.dispose();
    _wetFoodController.dispose();
    super.dispose();
  }
}