import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../models/recipetype.dart';
import '../providers/recipe_provider.dart';
import '../services/hive_service.dart';

class RecipeEditPage extends StatefulWidget {
  final Recipe? recipe; // if null -> create
  final List<RecipeType> types;
  RecipeEditPage({this.recipe, required this.types});
  @override
  _RecipeEditPageState createState() => _RecipeEditPageState();
}

class _RecipeEditPageState extends State<RecipeEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  String? _selectedTypeId;
  String _imagePath = '';
  List<TextEditingController> _ingredients = [];
  List<TextEditingController> _steps = [];
  @override
  void initState() {
    super.initState();
    final r = widget.recipe;
    _titleController = TextEditingController(text: r?.title ?? '');
    _selectedTypeId =
        r?.typeId ?? (widget.types.isNotEmpty ? widget.types.first.id : null);
    _imagePath = r?.imagePath ?? '';
    if (r != null) {
      _ingredients =
          r.ingredients.map((s) => TextEditingController(text: s)).toList();
      _steps = r.steps.map((s) => TextEditingController(text: s)).toList();
    }
    if (_ingredients.isEmpty) _ingredients.add(TextEditingController());
    if (_steps.isEmpty) _steps.add(TextEditingController());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _ingredients.forEach((c) => c.dispose());
    _steps.forEach((c) => c.dispose());
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName =
          DateTime.now().millisecondsSinceEpoch.toString() + '_' + picked.name;
      final saved = await File(picked.path).copy('${appDir.path}/$fileName');
      setState(() => _imagePath = saved.path);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final prov = Provider.of<RecipeProvider>(context, listen: false);
    final id = widget.recipe?.id ?? prov.createId();
    final recipe = Recipe(
      id: id,
      title: _titleController.text.trim(),
      typeId: _selectedTypeId ?? '',
      imagePath: _imagePath,
      ingredients: _ingredients
          .map((c) => c.text.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      steps:
          _steps.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList(),
    );
    if (widget.recipe == null) {
      prov.addRecipe(recipe);
    } else {
      final box = HiveService.box();
      box.put(id, recipe);
      prov.notifyListeners();
    }
    context.push(
      '/recipe/detail/${recipe.id}',
      extra: widget.types,
    );
  }

  Widget _buildDynamicList(
      String label, List<TextEditingController> list, VoidCallback onAdd) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        ...list.asMap().entries.map((e) {
          final idx = e.key;
          final ctrl = e.value;
          return Row(
            children: [
              Expanded(
                  child: TextFormField(
                      controller: ctrl,
                      validator: (v) => v!.isEmpty ? 'Required' : null)),
              IconButton(
                  onPressed: () {
                    setState(() {
                      list.removeAt(idx);
                    });
                  },
                  icon: Icon(Icons.remove_circle))
            ],
          );
        }).toList(),
        TextButton.icon(
            onPressed: onAdd, icon: Icon(Icons.add), label: Text('Add'))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text(widget.recipe == null ? 'Create Recipe' : 'Edit Recipe')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                  validator: (v) => v!.isEmpty ? 'Enter title' : null),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedTypeId,
                items: widget.types
                    .map((t) =>
                        DropdownMenuItem(value: t.id, child: Text(t.name)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedTypeId = v),
                decoration: InputDecoration(labelText: 'Recipe Type'),
              ),
              SizedBox(height: 12),
              (_imagePath.isNotEmpty && File(_imagePath).existsSync())
                  ? Image.file(
                      File(_imagePath),
                      height: 180,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: Center(child: Text('No image')),
                    ),
              TextButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.photo),
                  label: Text('Choose Image')),
              SizedBox(height: 12),
              _buildDynamicList(
                  'Ingredients',
                  _ingredients,
                  () => setState(
                      () => _ingredients.add(TextEditingController()))),
              SizedBox(height: 12),
              _buildDynamicList('Steps', _steps,
                  () => setState(() => _steps.add(TextEditingController()))),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _save, child: Text('Save'))
            ],
          ),
        ),
      ),
    );
  }
}
