import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:new_recipe_app/models/recipetype.dart';
import 'package:new_recipe_app/services/hive_service.dart';
import '../models/recipe.dart';

class RecipeProvider with ChangeNotifier {
  final StreamController<List<Recipe>> _controller =
      StreamController.broadcast();
  Stream<List<Recipe>> get recipesStream => _controller.stream;

  List<Recipe> _recipes = [];
  StreamSubscription<List<Recipe>>? _sub;
  late Box<Recipe> _box;
  StreamSubscription? _hiveSub;

  RecipeProvider() {
    _init();
    _sub = recipesStream.listen((list) {
      _recipes = list;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _hiveSub?.cancel();
    _controller.close();
    super.dispose();
  }

  Future<void> _init() async {
    _box = HiveService.box();
    await _seedRecipeTypes();
    _hiveSub = _box.watch().listen((_) => _pushCurrent());
    _pushCurrent();
  }

  Future<void> _seedRecipeTypes() async {
    try {
      final data = await rootBundle.loadString('assets/recipetypes.json');
      if (data.isNotEmpty) {
        final arr = json.decode(data) as List<dynamic>;
        await HiveService.seedIfEmpty(arr.cast<Map<String, dynamic>>());
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error seeding recipe types: $e");
    }
  }

  void _pushCurrent() {
    final list = _box.values.toList();
    _controller.add(list);
  }

  List<Recipe> get allRecipes => _recipes;

  List<Recipe> filterByType(String? typeId) {
    if (typeId == null || typeId.isEmpty) return _recipes;
    return _recipes.where((r) => r.typeId == typeId).toList();
  }

  Future<void> addRecipe(Recipe r) async {
    await _box.put(r.id, r);
    _pushCurrent();
  }

  Future<void> updateRecipe(Recipe r) async {
    await _box.put(r.id, r);
    _pushCurrent();
  }

  Future<void> deleteRecipe(String id) async {
    await _box.delete(id);
    _pushCurrent();
  }

  String createId() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<void> disposeRepo() async {
    await _hiveSub?.cancel();
    await _controller.close();
  }
}
