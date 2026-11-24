import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../models/recipe.dart';

class RecipesApiException implements Exception {
  const RecipesApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Jedina trieda, ktora komunikuje s DummyJSON serverom.
class RecipesApi {
  RecipesApi({http.Client? client}) : _client = client ?? http.Client();

  static const String _host = 'dummyjson.com';
  final http.Client _client;
  final Random _random = Random();

  /// V rezime Slow network server kazdu poziadavku zdrzi o 0 az 3000 ms.
  /// Oneskorenie vykonava server cez parameter ?delay=..., nie Flutter UI.
  void _addDelay(Map<String, String> params, bool slowNetwork) {
    if (slowNetwork) {
      params['delay'] = '${_random.nextInt(3001)}';
    }
  }

  /// Zoznam alebo serverove hladanie; vratane sortovania a strankovania.
  Future<RecipesPage> getRecipes({
    int limit = 10,
    int skip = 0,
    String query = '',
    String? sortBy,
    String order = 'desc',
    bool slowNetwork = false,
    bool simulate503 = false,
  }) async {
    if (simulate503) {
      final errorParams = <String, String>{};
      _addDelay(errorParams, slowNetwork);
      // Endpoint na testovanie chyboveho HTTP statusu.
      await _getJson(Uri.https(_host, '/http/503', errorParams));
      throw const RecipesApiException(
        'HTTP 503: Služba je dočasne nedostupná. Skúste to znova.',
      );
    }

    final params = <String, String>{
      'limit': '$limit',
      'skip': '$skip',
      'select': 'id,name,cuisine,prepTimeMinutes,rating,image',
    };

    if (sortBy != null) {
      params['sortBy'] = sortBy;
      params['order'] = order;
    }

    _addDelay(params, slowNetwork);

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

  /// Detail receptu - aj tato HTTP poziadavka respektuje Slow network.
  Future<Recipe> getRecipe(int id, {bool slowNetwork = false}) async {
    final params = <String, String>{};
    _addDelay(params, slowNetwork);
    final uri = Uri.https(_host, '/recipes/$id', params);
    return Recipe.fromJson(await _getJson(uri));
  }

  Future<RecipesPage> searchRecipes(
    String query, {
    int limit = 10,
    int skip = 0,
    String? sortBy,
    String order = 'desc',
    bool slowNetwork = false,
    bool simulate503 = false,
  }) {
    return getRecipes(
      query: query,
      limit: limit,
      skip: skip,
      sortBy: sortBy,
      order: order,
      slowNetwork: slowNetwork,
      simulate503: simulate503,
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
        throw const FormatException('Neplatný formát JSON.');
      }
      return data;
    } on FormatException {
      throw const RecipesApiException('Server vrátil neplatné dáta.');
    }
  }

  void dispose() => _client.close();
}
