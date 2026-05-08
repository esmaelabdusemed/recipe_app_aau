import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class RecipeService {
  final String baseUrl = "https://www.themealdb.com/api/json/v1/1";

  Future<List<Recipe>> fetchAllCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/filter.php?c=Seafood'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List meals = data['meals'];
      return meals.map((json) => Recipe.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  Future<Recipe> fetchRecipeDetails(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/lookup.php?i=$id'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final meal = data['meals'][0];
      
      List<String> ingredients = [];
      for (int i = 1; i <= 20; i++) {
        final ingredient = meal['strIngredient$i'];
        if (ingredient != null && ingredient.isNotEmpty) {
          ingredients.add(ingredient);
        }
      }

      return Recipe(
        id: meal['idMeal'],
        name: meal['strMeal'],
        imageUrl: meal['strMealThumb'],
        ingredients: ingredients,
        youtubeUrl: meal['strYoutube'] ?? '',
      );
    } else {
      throw Exception('Failed to load details');
    }
  }
}