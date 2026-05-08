import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// ----------------------------------------------------------------------
// 1. DATA MODEL & SERVICE (WITH CACHING LOGIC)
// ----------------------------------------------------------------------
class Recipe {
  final String id;
  final String name;
  final String imageUrl;
  final List<String> ingredients;
  final String instructions;
  final String youtubeUrl;

  Recipe({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.ingredients,
    required this.instructions,
    required this.youtubeUrl,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      imageUrl: json['strMealThumb'] ?? '',
      ingredients: [],
      instructions: json['strInstructions'] ?? '',
      youtubeUrl: json['strYoutube'] ?? '',
    );
  }
}

class RecipeService {
  final String baseUrl = "https://www.themealdb.com/api/json/v1/1";

  Future<List<Recipe>> fetchByCategory(String category) async {
    String cat = (category == 'All') ? 'Seafood' : category;
    final prefs = await SharedPreferences.getInstance();

    try {
      final response = await http
          .get(Uri.parse('$baseUrl/filter.php?c=$cat'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final mealsJson = response.body;
        await prefs.setString('cache_$cat', mealsJson); // SAVE TO CACHE

        final meals = json.decode(mealsJson)['meals'] as List;
        return meals.map((json) => Recipe.fromJson(json)).toList();
      } else {
        throw Exception("API connection failed");
      }
    } catch (e) {
      // OFFLINE MODE: Check the Cache
      final cachedData = prefs.getString('cache_$cat');
      if (cachedData != null) {
        final meals = json.decode(cachedData)['meals'] as List;
        return meals.map((json) => Recipe.fromJson(json)).toList();
      } else {
        throw Exception("API connection failed");
      }
    }
  }

  Future<Recipe> fetchRecipeDetails(String id) async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final response = await http
          .get(Uri.parse('$baseUrl/lookup.php?i=$id'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final mealJson = response.body;
        await prefs.setString('detail_$id', mealJson);
        return _parseDetail(mealJson);
      } else {
        throw Exception("Failed to load");
      }
    } catch (e) {
      final cachedDetail = prefs.getString('detail_$id');
      if (cachedDetail != null) {
        return _parseDetail(cachedDetail);
      }
      throw Exception("API connection failed");
    }
  }

  Recipe _parseDetail(String jsonStr) {
    final meal = json.decode(jsonStr)['meals'][0];
    List<String> ingredients = [];
    for (int i = 1; i <= 20; i++) {
      final ing = meal['strIngredient$i'];
      final msr = meal['strMeasure$i'];
      if (ing != null && ing.toString().trim().isNotEmpty) {
        ingredients.add("${msr ?? ''} $ing".trim());
      }
    }
    return Recipe(
      id: meal['idMeal'],
      name: meal['strMeal'],
      imageUrl: meal['strMealThumb'],
      ingredients: ingredients,
      instructions: meal['strInstructions'] ?? '',
      youtubeUrl: meal['strYoutube'] ?? '',
    );
  }
}

// ----------------------------------------------------------------------
// 2. MAIN GRID SCREEN
// ----------------------------------------------------------------------
class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final RecipeService _service = RecipeService();
  List<Recipe> _recipes = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData(_selectedCategory);
  }

  void _loadData(String category) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await _service.fetchByCategory(category);
      setState(() {
        _recipes = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "API connection failed";
      });
    }
  }

  void _showRecipeDetails(String id) {
    showDialog(
      context: context,
      builder: (context) =>
          Center(child: RecipeFloatingMiddleCard(recipeId: id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40, 60, 40, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AAU Gourmet',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // STYLISH CATEGORY BAR
                  SizedBox(
                    height: 45,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children:
                          [
                            'All',
                            'Beef',
                            'Chicken',
                            'Vegan',
                            'Dessert',
                            'Pasta',
                          ].map((cat) {
                            bool isSelected = _selectedCategory == cat;
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() => _selectedCategory = cat);
                                  _loadData(cat);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 25,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.orange
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.orange
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      cat,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_errorMessage != null && _recipes.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => _loadData(_selectedCategory),
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
            )
          else if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: Colors.orange),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 30,
                  mainAxisSpacing: 30,
                ),
                delegate: SliverChildBuilderDelegate((context, i) {
                  final r = _recipes[i];
                  return GestureDetector(
                    onTap: () => _showRecipeDetails(r.id),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.network(
                                  r.imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 20,
                              left: 10,
                              right: 10,
                            ),
                            child: Text(
                              r.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }, childCount: _recipes.length),
              ),
            ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// 3. THE FLOATING MIDDLE CARD
// ----------------------------------------------------------------------
class RecipeFloatingMiddleCard extends StatelessWidget {
  final String recipeId;
  const RecipeFloatingMiddleCard({super.key, required this.recipeId});

  Future<void> _launchYouTube(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final RecipeService service = RecipeService();

    return Material(
      color: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.75,
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 50)],
        ),
        child: FutureBuilder<Recipe>(
          future: service.fetchRecipeDetails(recipeId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  snapshot.error.toString(),
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
            if (!snapshot.hasData)
              return const Center(
                child: CircularProgressIndicator(color: Colors.orange),
              );

            final r = snapshot.data!;
            List<String> steps = r.instructions
                .split(RegExp(r'\.|\r\n'))
                .where((s) => s.trim().length > 3)
                .toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 40, 40, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          r.name,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 30),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.network(
                            r.imageUrl,
                            width: double.infinity,
                            height: 450,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // YOUTUBE BUTTON (FIXED)
                        if (r.youtubeUrl.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 35),
                            child: ElevatedButton.icon(
                              onPressed: () => _launchYouTube(r.youtubeUrl),
                              icon: const Icon(
                                Icons.play_circle_fill,
                                color: Colors.white,
                                size: 30,
                              ),
                              label: const Text(
                                "WATCH VIDEO TUTORIAL",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 70),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                            ),
                          ),

                        const Text(
                          "Ingredients",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ...r.ingredients.map(
                          (ing) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.orange,
                                  size: 24,
                                ),
                                const SizedBox(width: 15),
                                Text(
                                  ing,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: Divider(thickness: 2),
                        ),
                        const Text(
                          "Cooking Instructions",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 25),
                        ...steps.asMap().entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 30),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    color: Colors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    "${entry.key + 1}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 25),
                                Expanded(
                                  child: Text(
                                    entry.value.trim(),
                                    style: const TextStyle(
                                      fontSize: 19,
                                      height: 1.6,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
