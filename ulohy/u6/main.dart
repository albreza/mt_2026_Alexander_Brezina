import 'dart:async';

import 'package:flutter/material.dart';

import 'models/recipe.dart';
import 'screens/recipes_by_tag_screen.dart';
import 'services/recipes_api.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recepty',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const RecipesScreen(),
    );
  }
}

enum RecipeSort { original, ratingDesc, ratingAsc, nameAsc }

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  static const int _pageSize = 10;
  static const Duration _searchDebounce = Duration(milliseconds: 350);

  final RecipesApi _api = RecipesApi();
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchTimer;
  int _requestVersion = 0;

  List<Recipe> _recipes = [];
  int _total = 0;
  int _skip = 0;
  String _query = '';
  RecipeSort _sort = RecipeSort.original;
  bool _isLoading = false;
  bool _slowNetwork = false;
  bool _simulate503 = false;
  String? _error;

  int get _currentPage => (_skip ~/ _pageSize) + 1;
  int get _pageCount => (_total / _pageSize).ceil();

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  /// Kazde spustene nacitanie dostane cislo.
  /// Vysledok starej poziadavky nikdy neprepise novsi dopyt.
  /// Pri refreshi _recipes nezmazeme, takze stare karty ostanu viditelne.
  Future<void> _loadRecipes({bool clearBeforeLoad = false}) async {
    final int thisRequest = ++_requestVersion;

    setState(() {
      _isLoading = true;
      _error = null;
      if (clearBeforeLoad) {
        _recipes = [];
        _total = 0;
      }
    });

    String? sortBy;
    String order = 'desc';
    switch (_sort) {
      case RecipeSort.original:
        break;
      case RecipeSort.ratingDesc:
        sortBy = 'rating';
        order = 'desc';
        break;
      case RecipeSort.ratingAsc:
        sortBy = 'rating';
        order = 'asc';
        break;
      case RecipeSort.nameAsc:
        sortBy = 'name';
        order = 'asc';
        break;
    }

    // Stav parametrov zachytime pri odoslani, nie pri prijati odpovede.
    final query = _query;
    final skip = _skip;
    final slowNetwork = _slowNetwork;
    final simulate503 = _simulate503;

    try {
      final page = await _api.getRecipes(
        limit: _pageSize,
        skip: skip,
        query: query,
        sortBy: sortBy,
        order: order,
        slowNetwork: slowNetwork,
        simulate503: simulate503,
      );
      if (!mounted || thisRequest != _requestVersion) return;
      setState(() {
        _recipes = page.recipes;
        _total = page.total;
        _skip = page.skip;
      });
    } catch (e) {
      if (!mounted || thisRequest != _requestVersion) return;
      setState(() {
        _error = e is RecipesApiException
            ? e.message
            : 'Nepodarilo sa načítať recepty. Skúste to znova.';
      });
    } finally {
      if (mounted && thisRequest == _requestVersion) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// AS-YOU-TYPE: okamzite zneplatni starsie poziadavky, potom debounce.
  /// TextField nie je blokovany pocas nacitavania.
  void _onSearchChanged(String text) {
    _searchTimer?.cancel();
    ++_requestVersion; // stare odpovede nepatria k aktualnemu textu

    final query = text.trim();
    setState(() {
      _query = query;
      _skip = 0;
      _total = 0;
      _recipes = [];
      _error = null;
      _isLoading = true;
    });

    if (query.isEmpty) {
      _loadRecipes(); // prazdne hladanie = povodny zoznam
    } else {
      _searchTimer = Timer(_searchDebounce, () {
        _loadRecipes();
      });
    }
  }

  void _submitSearch() {
    _searchTimer?.cancel();
    _loadRecipes();
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
  }

  void _goToPage(int step) {
    if (_isLoading) return;
    final newSkip = _skip + step * _pageSize;
    if (newSkip < 0 || newSkip >= _total) return;
    setState(() => _skip = newSkip);
    _loadRecipes(clearBeforeLoad: true);
  }

  void _changeSort(RecipeSort? value) {
    if (value == null || value == _sort) return;
    _searchTimer?.cancel();
    setState(() {
      _sort = value;
      _skip = 0;
    });
    _loadRecipes(clearBeforeLoad: true);
  }

  void _changeSlowNetwork(bool enabled) {
    if (_slowNetwork == enabled) return;
    _searchTimer?.cancel();
    setState(() => _slowNetwork = enabled);
    // Aktualizujeme vysledky a kazda nova request pouzije aktualny rezim.
    _loadRecipes();
  }

  void _changeTestMode(bool simulate503) {
    if (_simulate503 == simulate503) return;
    _searchTimer?.cancel();
    setState(() {
      _simulate503 = simulate503;
      _skip = 0;
    });
    _loadRecipes(clearBeforeLoad: true);
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    ++_requestVersion;
    _searchController.dispose();
    _api.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recepty'),
        actions: [
          IconButton(
            tooltip: 'Filtrovať recepty podľa tagu',
            icon: const Icon(Icons.local_offer_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => RecipesByTagScreen(
                    api: _api,
                    slowNetwork: _slowNetwork,
                    simulate503: _simulate503,
                    onOpenRecipe: (context, recipe) {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => RecipeDetailScreen(
                            id: recipe.id,
                            api: _api,
                            slowNetwork: _slowNetwork,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          PopupMenuButton<bool>(
            tooltip: 'Testovanie HTTP 503',
            icon: Icon(_simulate503 ? Icons.cloud_off_outlined : Icons.more_vert),
            onSelected: _changeTestMode,
            itemBuilder: (_) => [
              CheckedPopupMenuItem<bool>(
                value: false,
                checked: !_simulate503,
                child: const Text('Normálny režim'),
              ),
              CheckedPopupMenuItem<bool>(
                value: true,
                checked: _simulate503,
                child: const Text('Simulovať HTTP 503'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildControls(),
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            onSubmitted: (_) => _submitSearch(),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              isDense: true,
              border: const OutlineInputBorder(),
              hintText: 'Hľadať počas písania (napr. pasta)',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      tooltip: 'Zrušiť hľadanie',
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.close),
                    )
                  : null,
            ),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: const Text('Slow network'),
            subtitle: const Text('Náhodné oneskorenie 0–3000 ms na serveri'),
            value: _slowNetwork,
            onChanged: _changeSlowNetwork,
          ),
          Row(
            children: [
              const Text('Triediť: '),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<RecipeSort>(
                  isExpanded: true,
                  value: _sort,
                  onChanged: _changeSort,
                  items: const [
                    DropdownMenuItem(
                      value: RecipeSort.original,
                      child: Text('Pôvodné poradie'),
                    ),
                    DropdownMenuItem(
                      value: RecipeSort.ratingDesc,
                      child: Text('Hodnotenie: najvyššie'),
                    ),
                    DropdownMenuItem(
                      value: RecipeSort.ratingAsc,
                      child: Text('Hodnotenie: najnižšie'),
                    ),
                    DropdownMenuItem(
                      value: RecipeSort.nameAsc,
                      child: Text('Názov: A–Z'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_recipes.isEmpty && _isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Načítavam recepty...'),
          ],
        ),
      );
    }

    if (_recipes.isEmpty && _error != null) {
      return _errorPanel();
    }

    // Vlastny stav pre prazdne vysledky serveroveho hladania.
    if (_recipes.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadRecipes,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 88),
            const Icon(Icons.search_off, size: 60),
            const SizedBox(height: 12),
            Text(
              _query.isEmpty
                  ? 'Žiadne recepty nie sú dostupné.'
                  : 'Pre výraz „$_query“ sa nenašli žiadne recepty.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Center(child: Text('Skúste zadať iný názov receptu.')),
            if (_query.isNotEmpty)
              Center(
                child: TextButton(
                  onPressed: _clearSearch,
                  child: const Text('Vymazať hľadanie'),
                ),
              ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_isLoading) const LinearProgressIndicator(),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(child: Text(_error!)),
                    TextButton(
                      onPressed: _loadRecipes,
                      child: const Text('Skúsiť znova'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Zobrazených ${_recipes.length} z $_total receptov'),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadRecipes,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: _recipes.length,
              itemBuilder: (context, index) => _recipeCard(_recipes[index]),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.outlined(
                tooltip: 'Predchádzajúca strana',
                onPressed: _isLoading || _skip == 0
                    ? null
                    : () => _goToPage(-1),
                icon: const Icon(Icons.chevron_left),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('Strana $_currentPage z $_pageCount'),
              ),
              IconButton.outlined(
                tooltip: 'Ďalšia strana',
                onPressed: _isLoading || _skip + _pageSize >= _total
                    ? null
                    : () => _goToPage(1),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _recipeCard(Recipe recipe) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => RecipeDetailScreen(
                id: recipe.id,
                api: _api,
                slowNetwork: _slowNetwork,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              SizedBox(width: 100, height: 100, child: _image(recipe.image)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(recipe.name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    _detail(Icons.public, recipe.cuisine),
                    _detail(Icons.schedule, '${recipe.prepTimeMinutes} min'),
                    _detail(Icons.star_rounded, recipe.rating.toStringAsFixed(1)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorPanel() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadRecipes,
              icon: const Icon(Icons.refresh),
              label: const Text('Skúsiť znova'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Detail cez GET /recipes/{id}.
class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({
    super.key,
    required this.id,
    required this.api,
    required this.slowNetwork,
  });

  final int id;
  final RecipesApi api;
  final bool slowNetwork;

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  Recipe? _recipe;
  String? _error;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final recipe = await widget.api.getRecipe(
        widget.id,
        slowNetwork: widget.slowNetwork,
      );
      if (!mounted) return;
      setState(() => _recipe = recipe);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is RecipesApiException
            ? e.message
            : 'Nepodarilo sa načítať detail receptu.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail receptu')),
      body: _recipe == null
          ? Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error ?? 'Recept nebol nájdený.'),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _load,
                          child: const Text('Skúsiť znova'),
                        ),
                      ],
                    ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 240,
                    child: _image(_recipe!.image),
                  ),
                  const SizedBox(height: 16),
                  Text(_recipe!.name, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  _detail(Icons.public, _recipe!.cuisine),
                  _detail(Icons.schedule, 'Čas prípravy: ${_recipe!.prepTimeMinutes} min'),
                  _detail(Icons.star_rounded,
                      'Hodnotenie: ${_recipe!.rating.toStringAsFixed(1)}'),
                ],
              ),
            ),
    );
  }
}

Widget _image(String url) {
  if (url.isEmpty) return const Center(child: Icon(Icons.restaurant, size: 40));
  return Image.network(
    url,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) =>
        const Center(child: Icon(Icons.broken_image_outlined, size: 40)),
  );
}

Widget _detail(IconData icon, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 6),
        Flexible(child: Text(value)),
      ],
    ),
  );
}

