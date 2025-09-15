import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:new_recipe_app/providers/user_provider.dart';
import 'package:new_recipe_app/widgets/profile_widget.dart';
import 'package:provider/provider.dart';
import '../models/recipetype.dart';
import '../providers/recipe_provider.dart';
import 'recipe_detail_page.dart';
import 'recipe_edit_page.dart';
import '../services/hive_service.dart';
import '../models/recipe.dart';

class RecipeListPage extends StatefulWidget {
  @override
  _RecipeListPageState createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  List<RecipeType> types = [];
  String? selectedTypeId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTypes();
    });
  }

  Future<void> _loadTypes() async {
    final data = await rootBundle.loadString('assets/recipetypes.json');
    if (data.isNotEmpty) {
      final arr = json.decode(data) as List<dynamic>;
      final parsed = arr.map((e) => RecipeType.fromJson(e)).toList();
      setState(() => types = parsed);

      await HiveService.seedIfEmpty(arr.cast<Map<String, dynamic>>());
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipeProvider>();
    final user = context.watch<UserProvider>();

    final filteredRecipes = (selectedTypeId == null || selectedTypeId == '')
        ? provider.allRecipes
        : provider.allRecipes.where((r) => r.typeId == selectedTypeId).toList();

    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        backgroundColor: Theme.of(context).primaryColor,
        title: Row(
          children: [
            Text('Recipes', style: TextStyle(fontWeight: FontWeight.bold)),
            Spacer(),
            if (user.isLoggedIn)
              Text(
                'Hi, ${user.name ?? 'User'}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            SizedBox(width: 8),
            IconButton(
              icon: CircleAvatar(
                backgroundColor: user.isLoggedIn ? Colors.white : Colors.grey,
                child: Icon(
                  Icons.person,
                  color: user.isLoggedIn
                      ? Theme.of(context).primaryColor
                      : Colors.white,
                ),
              ),
              onPressed: () {
                if (user.isLoggedIn) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      content: ProfileWidget(),
                    ),
                  );
                } else {
                  context.push('/login');
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(
            '/recipe/edit',
            extra: {
              'types': types,
            },
          );
        },
        icon: Icon(Icons.add),
        label: Text('Add Recipe'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          // Dropdown filter
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              isExpanded: true,
              hint: Text('Choose recipe type'),
              value: selectedTypeId,
              items: [
                DropdownMenuItem(value: '', child: Text('All')),
                ...types
                    .map((t) =>
                        DropdownMenuItem(value: t.id, child: Text(t.name)))
                    .toList()
              ],
              onChanged: (v) =>
                  setState(() => selectedTypeId = (v == '') ? null : v),
            ),
          ),

          // Recipe list
          Expanded(
            child: filteredRecipes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.no_food,
                            size: 80, color: Colors.grey.shade400),
                        SizedBox(height: 12),
                        Text(
                          'No recipes found',
                          style: TextStyle(
                              fontSize: 18, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(12),
                    itemCount: filteredRecipes.length,
                    itemBuilder: (context, index) {
                      final r = filteredRecipes[index];
                      final typeName = types
                          .firstWhere((t) => t.id == r.typeId,
                              orElse: () => RecipeType(id: '', name: 'Unknown'))
                          .name;

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RecipeDetailPage(
                                  recipeId: r.id, types: types),
                            ),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.horizontal(
                                    left: Radius.circular(16)),
                                child: r.imagePath.isNotEmpty &&
                                        File(r.imagePath).existsSync()
                                    ? Image.file(File(r.imagePath),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover)
                                    : Container(
                                        width: 100,
                                        height: 100,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        child: Icon(Icons.fastfood, size: 40),
                                      ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        r.title,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        typeName,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.arrow_forward_ios, size: 16),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
