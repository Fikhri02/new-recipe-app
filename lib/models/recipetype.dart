class RecipeType {
  final String id;
  final String name;
  RecipeType({required this.id, required this.name});
  factory RecipeType.fromJson(Map<String, dynamic> json) {
    return RecipeType(id: json['id'].toString(), name: json['name']);
  }
}
