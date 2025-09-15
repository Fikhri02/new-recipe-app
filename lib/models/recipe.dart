import 'package:hive/hive.dart';
part 'recipe.g.dart';

@HiveType(typeId: 0)
class Recipe extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String typeId;

  @HiveField(3)
  String imagePath; // local file path

  @HiveField(4)
  List<String> ingredients;

  @HiveField(5)
  List<String> steps;
  Recipe({
    required this.id,
    required this.title,
    required this.typeId,
    required this.imagePath,
    required this.ingredients,
    required this.steps,
  });
}
// Note: recipe.g.dart is generated via build_runner when using Hive type adapters.
