import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import this
import 'screens/recipe_list_screen.dart';

void main() {
  runApp(const RecipeApp());
}

class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AAU Gourmet App',
      theme: ThemeData(
        useMaterial3: true,
        // Using a stylish serif font for that "Gourmet" feel
        textTheme: GoogleFonts.loraTextTheme(), 
        primarySwatch: Colors.orange,
      ),
      home: const RecipeListScreen(),
    );
  }
}