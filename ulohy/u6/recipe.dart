class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.prepTimeMinutes,
    required this.rating,
    required this.image,
  });

  final int id;
  final String name;
  final String cuisine;
  final int prepTimeMinutes;
  final double rating;
  final String image;

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      cuisine: json['cuisine'] as String,
      prepTimeMinutes: (json['prepTimeMinutes'] as num).toInt(),
      rating: (json['rating'] as num).toDouble(),
      image: json['image'] as String? ?? '',
    );
  }
}

/// Odpoved /recipes a /recipes/search obsahuje okrem receptov aj
/// informacie potrebne pre strankovanie.
class RecipesPage {
  const RecipesPage({
    required this.recipes,
    required this.total,
    required this.skip,
    required this.limit,
  });

  final List<Recipe> recipes;
  final int total;
  final int skip;
  final int limit;

  factory RecipesPage.fromJson(Map<String, dynamic> json) {
    return RecipesPage(
      recipes: (json['recipes'] as List<dynamic>)
          .map((item) => Recipe.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      skip: (json['skip'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
    );
  }
}
