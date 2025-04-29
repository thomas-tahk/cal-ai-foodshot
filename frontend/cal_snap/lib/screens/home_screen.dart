import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/food_entry.dart';
import '../models/dashboard_stats.dart';
import '../services/api_service.dart';
import 'food_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  List<FoodEntry> _foodEntries = [];
  DashboardStats _stats = DashboardStats.empty();
  bool _isLoading = true;
  bool _isScanning = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Load dashboard stats
      final stats = await _apiService.getDashboardStats();
      
      // Load food entries
      final foodEntries = await _apiService.getFoodEntries();
      
      // Update state
      setState(() {
        _stats = stats;
        _foodEntries = foodEntries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _scanFood() async {
    try {
      // Get image from camera
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      
      if (pickedFile == null) return;
      
      setState(() {
        _isScanning = true;
        _errorMessage = '';
      });
      
      // Upload and process the image
      final foodEntry = await _apiService.scanFood(File(pickedFile.path));
      
      if (foodEntry != null) {
        // Reload data to update dashboard and food list
        await _loadData();
      } else {
        setState(() {
          _errorMessage = 'Failed to process food image.';
          _isScanning = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cal Snap', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadData,
            child: Column(
              children: [
                // Error message (if any)
                if (_errorMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    color: Colors.red[100],
                    width: double.infinity,
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                
                // Dashboard Stats
                _buildDashboardStats(),
                
                // Recently Eaten Section
                Expanded(
                  child: _buildRecentlyEaten(),
                ),
              ],
            ),
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isScanning ? null : _scanFood,
        backgroundColor: Colors.green,
        child: _isScanning 
          ? const CircularProgressIndicator(color: Colors.white)
          : const Icon(Icons.camera_alt),
      ),
    );
  }

  Widget _buildDashboardStats() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.green.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calories
          Text(
            'Calories Remaining: ${_stats.remainingCalories}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 1 - (_stats.totalCalories / 2500),
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              _stats.remainingCalories > 500 ? Colors.green : Colors.red,
            ),
            minHeight: 12,
          ),
          const SizedBox(height: 16),
          
          // Macros
          const Text(
            'Macronutrients Consumed Today:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // Protein
          _buildMacroRow(
            'Protein', 
            _stats.proteinGrams,
            Colors.blue,
          ),
          
          // Carbs
          _buildMacroRow(
            'Carbs', 
            _stats.carbGrams,
            Colors.orange,
          ),
          
          // Fat
          _buildMacroRow(
            'Fat', 
            _stats.fatGrams,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRow(String name, int grams, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: grams / 100, // Simple scale for visualization
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
          const SizedBox(width: 8),
          Text('${grams}g'),
        ],
      ),
    );
  }

  Widget _buildRecentlyEaten() {
    if (_foodEntries.isEmpty) {
      return const Center(
        child: Text(
          'No food entries yet. Tap the camera button to get started!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Recently Eaten',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _foodEntries.length,
            itemBuilder: (context, index) {
              final foodEntry = _foodEntries[index];
              return _buildFoodEntryCard(foodEntry);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFoodEntryCard(FoodEntry foodEntry) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodDetailScreen(foodId: foodEntry.id),
          ),
        ).then((_) => _loadData()), // Refresh data when returning from detail screen
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Food Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  foodEntry.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Icon(Icons.no_food, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Food Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      foodEntry.foodName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Calories: ${foodEntry.calories ?? "N/A"}',
                      style: const TextStyle(color: Colors.black87),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'P: ${foodEntry.proteinGrams ?? "N/A"}g | C: ${foodEntry.carbGrams ?? "N/A"}g | F: ${foodEntry.fatGrams ?? "N/A"}g',
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    ),
                  ],
                ),
              ),
              
              // Timestamp
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatTime(foodEntry.scanTimestamp),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    if (dateTime.day == now.day && 
        dateTime.month == now.month && 
        dateTime.year == now.year) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
    return '${dateTime.month}/${dateTime.day}';
  }
} 