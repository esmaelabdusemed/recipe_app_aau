class Recipe {
  final String id;
  final String name;
  final String imageUrl;
  final List<String> ingredients;
  final String youtubeUrl;

  Recipe({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.ingredients,
    required this.youtubeUrl,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      imageUrl: json['strMealThumb'] ?? '',
      ingredients: [], // Populated in the service
      youtubeUrl: json['strYoutube'] ?? '',
    );
  }
}