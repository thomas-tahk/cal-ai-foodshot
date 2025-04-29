class FoodEntry {
  final int id;
  final String imageUrl;
  final String foodName;
  final int? calories;
  final int? proteinGrams;
  final int? carbGrams;
  final int? fatGrams;
  final int quantity;
  final Map<String, dynamic>? ingredients;
  final DateTime scanTimestamp;

  FoodEntry({
    required this.id,
    required this.imageUrl,
    required this.foodName,
    this.calories,
    this.proteinGrams,
    this.carbGrams,
    this.fatGrams,
    this.quantity = 1,
    this.ingredients,
    required this.scanTimestamp,
  });

  factory FoodEntry.fromJson(Map<String, dynamic> json) {
    return FoodEntry(
      id: json['id'],
      imageUrl: json['image_url'],
      foodName: json['food_name'] ?? 'Unknown Food',
      calories: json['calories'],
      proteinGrams: json['protein_grams'],
      carbGrams: json['carb_grams'],
      fatGrams: json['fat_grams'],
      quantity: json['quantity'] ?? 1,
      ingredients: json['ingredients'],
      scanTimestamp: DateTime.parse(json['scan_timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'food_name': foodName,
      'calories': calories,
      'protein_grams': proteinGrams,
      'carb_grams': carbGrams,
      'fat_grams': fatGrams,
      'quantity': quantity,
      'ingredients': ingredients,
      'scan_timestamp': scanTimestamp.toIso8601String(),
    };
  }
} 