import 'package:flutter/material.dart';
import '../models/food_entry.dart';
import '../services/api_service.dart';

class FoodDetailScreen extends StatefulWidget {
  final int foodId;

  const FoodDetailScreen({Key? key, required this.foodId}) : super(key: key);

  @override
  _FoodDetailScreenState createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  final ApiService _apiService = ApiService();
  FoodEntry? _foodEntry;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadFoodEntry();
  }

  Future<void> _loadFoodEntry() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final foodEntry = await _apiService.getFoodEntry(widget.foodId);
      setState(() {
        _foodEntry = foodEntry;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load food details: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_foodEntry?.foodName ?? 'Food Details'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _foodEntry == null
              ? Center(
                  child: Text(
                    _errorMessage.isEmpty
                        ? 'Food entry not found'
                        : _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : _buildFoodDetails(),
    );
  }

  Widget _buildFoodDetails() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food Image
          SizedBox(
            width: double.infinity,
            height: 250,
            child: Image.network(
              _foodEntry!.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
                ),
              ),
            ),
          ),
          
          // Food Info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Food Name
                Text(
                  _foodEntry!.foodName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Quantity
                Row(
                  children: [
                    const Text(
                      'Quantity:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_foodEntry!.quantity}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Nutritional Info
                const Text(
                  'Nutritional Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Calories
                _buildNutritionRow(
                  'Calories',
                  _foodEntry!.calories != null
                      ? '${_foodEntry!.calories} kcal'
                      : 'N/A',
                  Colors.red,
                ),
                
                // Protein
                _buildNutritionRow(
                  'Protein',
                  _foodEntry!.proteinGrams != null
                      ? '${_foodEntry!.proteinGrams} g'
                      : 'N/A',
                  Colors.blue,
                ),
                
                // Carbs
                _buildNutritionRow(
                  'Carbohydrates',
                  _foodEntry!.carbGrams != null
                      ? '${_foodEntry!.carbGrams} g'
                      : 'N/A',
                  Colors.orange,
                ),
                
                // Fat
                _buildNutritionRow(
                  'Fat',
                  _foodEntry!.fatGrams != null
                      ? '${_foodEntry!.fatGrams} g'
                      : 'N/A',
                  Colors.purple,
                ),
                
                // Timestamp
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Scanned on ${_formatDateTime(_foodEntry!.scanTimestamp)}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                
                // Ingredients Section (if available)
                if (_foodEntry!.ingredients != null && _foodEntry!.ingredients!.isNotEmpty)
                  _buildIngredientsSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: color.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Ingredients',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._foodEntry!.ingredients!.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(entry.key),
                Text(
                  '${entry.value?.round() ?? "N/A"} kcal',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day}/${dateTime.year} at '
        '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
} 