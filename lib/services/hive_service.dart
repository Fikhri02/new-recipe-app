import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/recipe.dart';

class HiveService {
  static const String recipeBox = 'recipesBox';
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    Directory dir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(dir.path);
    Hive.registerAdapter(RecipeAdapter());
    await Hive.openBox<Recipe>(recipeBox);
  }

  static Box<Recipe> box() => Hive.box<Recipe>(recipeBox);
  static Future<void> seedIfEmpty(
      List<Map<String, dynamic>> jsonRecipeTypes) async {
    final box = Hive.box<Recipe>(recipeBox);
    if (box.isEmpty) {
      // create sample recipes when starting the app
      final sample1 = Recipe(
        id: 'r1',
        title: 'Simple Pancakes',
        typeId: jsonRecipeTypes.first['id'].toString(),
        imagePath: '',
        ingredients: ['1 cup flour', '1 egg', '1 cup milk', 'pinch salt'],
        steps: ['Mix all ingredients', 'Cook on skillet until golden'],
      );
      final sample2 = Recipe(
        id: 'r2',
        title: 'Grilled Cheese',
        typeId: jsonRecipeTypes.length > 1
            ? jsonRecipeTypes[1]['id'].toString()
            : jsonRecipeTypes.first['id'].toString(),
        imagePath: '',
        ingredients: ['2 slices bread', 'Cheese slices', 'Butter'],
        steps: ['Butter bread', 'Assemble cheese', 'Grill until golden brown'],
      );
      await box.put(sample1.id, sample1);
      await box.put(sample2.id, sample2);
    }
  }
}
