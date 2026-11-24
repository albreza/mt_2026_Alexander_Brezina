import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/recipe.dart';

class RecipesApiException implements Exception {
  const RecipesApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Vsetky HTTP poziadavky v aplikacii su na jednom mieste.
class RecipesApi {
  RecipesApi({http.Client? client}) : _client = client ?? http.Client();

  static const String _host = 'dummyjson.com';
  final http.Client _client;

  /// Parametre pre zoznam, vyhladavanie, strankovanie a triedenie.
  /// select musi obsahovat vsetky polia, ktore potrebuje model a UI.
  Future<RecipesPage> getRecipes({
    int limit = 10,
    int skip = 0,
    String query = '',
    String? sortBy,
    String order = 'desc',
    int delayMs = 1500,
    bool simulate503 = false,
  }) async {
    if (simulate503) {
      await _getJson(Uri.https(_host, '/http/503', {'delay': '$delayMs'}));
      throw const RecipesApiException('Test HTTP 503 zlyhal.');
    }

    final params = <String, String>{
      'limit': '$limit',
      'skip': '$skip',
      'select': 'id,name,cuisine,prepTimeMinutes,rating,image',
      'delay': '$delayMs',
    };

    if (sortBy != null) {
      params['sortBy'] = sortBy;
      params['order'] = order;
    }

    final trimmedQuery = query.trim();
    if (trimmedQuery.isNotEmpty) {
      params['q'] = trimmedQuery;
    }

    final uri = Uri.https(
      _host,
      trimmedQuery.isEmpty ? '/recipes' : '/recipes/search',
      params,
    );
    return RecipesPage.fromJson(await _getJson(uri));
  }

  /// Jeden recept (napr. /recipes/1).
  Future<Recipe> getRecipe(int id) async {
    final uri = Uri.https(_host, '/recipes/$id');
    return Recipe.fromJson(await _getJson(uri));
  }

  /// Samostatna metoda pre vyhladavanie (alternativa k getRecipes(query: ...)).
  Future<RecipesPage> searchRecipes(
    String query, {
    int limit = 10,
    int skip = 0,
    String? sortBy,
    String order = 'desc',
  }) {
    return getRecipes(
      query: query,
      limit: limit,
      skip: skip,
      sortBy: sortBy,
      order: order,
    );
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    late final http.Response response;
    try {
      response = await _client.get(uri).timeout(const Duration(seconds: 12));
    } on TimeoutException {
      throw const RecipesApiException(
        'Server odpovedá príliš dlho. Skúste to znova.',
      );
    } on http.ClientException {
      throw const RecipesApiException(
        'Nepodarilo sa pripojiť k serveru. Skontrolujte internet.',
      );
    }

    if (response.statusCode == 503) {
      throw const RecipesApiException(
        'HTTP 503: Služba je dočasne nedostupná. Skúste to znova.',
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw RecipesApiException(
        'Server vrátil chybu HTTP ${response.statusCode}.',
      );
    }

    try {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Neplatny format JSON.');
      }
      // Ak mock endpoint vrati JSON so statusom 503, osetrime aj to.
      if (uri.path == '/http/503' && data['status'].toString() == '503') {
        throw const RecipesApiException(
          'HTTP 503: Služba je dočasne nedostupná. Skúste to znova.',
        );
      }
      return data;
    } on FormatException {
      throw const RecipesApiException('Server vrátil neplatné dáta.');
    }
  }

  void dispose() => _client.close();
}
