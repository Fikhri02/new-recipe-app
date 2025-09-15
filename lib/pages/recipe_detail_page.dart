import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/recipetype.dart';
import '../services/hive_service.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import 'recipe_edit_page.dart';

class RecipeDetailPage extends StatelessWidget {
  final String recipeId;
  final List<RecipeType> types;
  const RecipeDetailPage({required this.recipeId, required this.types});

  @override
  Widget build(BuildContext context) {
    final box = HiveService.box();
    final Recipe? recipe = box.get(recipeId);

    if (recipe == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Not found')),
        body: const Center(child: Text('Recipe not found')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  recipe.imagePath.isNotEmpty &&
                          File(recipe.imagePath).existsSync()
                      ? Image.file(File(recipe.imagePath), fit: BoxFit.cover)
                      : Container(
                          color: Colors.grey[300],
                        ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 16,
                    right: 16,
                    child: Text(
                      recipe.title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(blurRadius: 6, color: Colors.black45),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  context.push(
                    '/recipe/edit',
                    extra: {
                      'types': types,
                      'recipe': recipe,
                    },
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Delete Recipe'),
                      content: const Text(
                          'Are you sure you want to delete this recipe?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    Provider.of<RecipeProvider>(context, listen: false)
                        .deleteRecipe(recipeId);
                    Navigator.pop(context);
                  }
                },
              )
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ingredients
                  const Text(
                    "Ingredients",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      child: Column(
                        children: recipe.ingredients
                            .map((i) => ListTile(
                                  dense: true,
                                  leading: const Icon(Icons.check_circle,
                                      color: Colors.green),
                                  title: Text(i),
                                ))
                            .toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Steps
                  const Text(
                    "Steps",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      child: Column(
                        children: recipe.steps
                            .asMap()
                            .entries
                            .map((e) => ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.deepOrange,
                                    foregroundColor: Colors.white,
                                    child: Text('${e.key + 1}'),
                                  ),
                                  title: Text(e.value),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
