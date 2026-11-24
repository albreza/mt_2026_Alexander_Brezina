import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../services/recipes_api.dart';

/// ETAPA 3: nova funkcia nezavisla od vyhladavania textu.
/// Tagy sa citaju z /recipes/tags a vysledky podla vyberu pouzivatela
/// zo serveroveho endpointu /recipes/tag/{tag}.
class RecipesByTagScreen extends StatefulWidget {
  const RecipesByTagScreen({
    super.key,
    required this.api,
    required this.slowNetwork,
    required this.simulate503,
    required this.onOpenRecipe,
  });

  final RecipesApi api;
  final bool slowNetwork;
  final bool simulate503;
  final void Function(BuildContext context, Recipe recipe) onOpenRecipe;

  @override
  State<RecipesByTagScreen> createState() => _RecipesByTagScreenState();
}

class _RecipesByTagScreenState extends State<RecipesByTagScreen> {
  static const int _pageSize = 10;

  List<String> _tags = [];
  String? _selectedTag;
  List<Recipe> _recipes = [];
  int _skip = 0;
  int _total = 0;

  bool _tagsLoading = false;
  bool _resultsLoading = false;
  bool _simulate503 = false;
  String? _tagsError;
  String? _resultsError;

  // Stare odpovede nemozu prepisat novo zvoleny tag ani aktualnu stranu.
  int _tagsRequestVersion = 0;
  int _resultsRequestVersion = 0;

  int get _pageCount => (_total + _pageSize - 1) ~/ _pageSize;
  int get _currentPage => (_skip ~/ _pageSize) + 1;

  @override
  void initState() {
    super.initState();
    _simulate503 = widget.simulate503;
    _loadTags();
  }

  /// Vlastne nacitavanie, chyba a prazdny stav pre zoznam tagov.
  Future<void> _loadTags() async {
    final version = ++_tagsRequestVersion;
    setState(() {
      _tagsLoading = true;
      _tagsError = null;
    });

    try {
      final tags = await widget.api.getTags(
        slowNetwork: widget.slowNetwork,
        simulate503: _simulate503,
      );
      if (!mounted || version != _tagsRequestVersion) return;
      setState(() => _tags = tags);
    } catch (error) {
      if (!mounted || version != _tagsRequestVersion) return;
      setState(() {
        _tagsError = error is RecipesApiException
            ? error.message
            : 'Nepodarilo sa načítať tagy.';
      });
    } finally {
      if (mounted && version == _tagsRequestVersion) {
        setState(() => _tagsLoading = false);
      }
    }
  }

  void _chooseTag(String? tag) {
    if (tag == _selectedTag) return;
    ++_resultsRequestVersion; // okamzite zneplatnenie starej odpovede
    setState(() {
      _selectedTag = tag;
      _skip = 0;
      _total = 0;
      _recipes = [];
      _resultsError = null;
      _resultsLoading = false;
    });
    if (tag != null) _loadResults();
  }

  /// Vlastne nacitavanie, chyba a prazdny stav pre recepty zvoleneho tagu.
  /// Pri obnove nechavame povodne recepty na obrazovke.
  Future<void> _loadResults({bool clearBeforeLoad = false}) async {
    final tag = _selectedTag;
    if (tag == null) return;
    final version = ++_resultsRequestVersion;
    final skip = _skip;
    final simulate503 = _simulate503;

    setState(() {
      _resultsLoading = true;
      _resultsError = null;
      if (clearBeforeLoad) {
        _recipes = [];
        _total = 0;
      }
    });

    try {
      final page = await widget.api.getRecipesByTag(
        tag,
        limit: _pageSize,
        skip: skip,
        slowNetwork: widget.slowNetwork,
        simulate503: simulate503,
      );
      if (!mounted || version != _resultsRequestVersion) return;
      setState(() {
        _recipes = page.recipes;
        _total = page.total;
        _skip = page.skip;
      });
    } catch (error) {
      if (!mounted || version != _resultsRequestVersion) return;
      setState(() {
        _resultsError = error is RecipesApiException
            ? error.message
            : 'Nepodarilo sa načítať recepty podľa tagu.';
      });
    } finally {
      if (mounted && version == _resultsRequestVersion) {
        setState(() => _resultsLoading = false);
      }
    }
  }

  void _goToPage(int direction) {
    if (_resultsLoading) return;
    final newSkip = _skip + direction * _pageSize;
    if (newSkip < 0 || newSkip >= _total) return;
    setState(() => _skip = newSkip);
    _loadResults(clearBeforeLoad: true);
  }

  void _changeTestMode(bool simulate503) {
    if (_simulate503 == simulate503) return;
    setState(() => _simulate503 = simulate503);
    if (_tags.isEmpty) {
      _loadTags();
    } else if (_selectedTag != null) {
      _loadResults(clearBeforeLoad: true);
    }
  }

  @override
  void dispose() {
    ++_tagsRequestVersion;
    ++_resultsRequestVersion;
    super.dispose();
    // API je zdielane s hlavnou obrazovkou, tu ho nezatvarame.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recepty podľa tagu'),
        actions: [
          PopupMenuButton<bool>(
            tooltip: 'Testovanie chyby v tagoch',
            icon: Icon(
              _simulate503 ? Icons.cloud_off_outlined : Icons.more_vert,
            ),
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_tagsLoading && _tags.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Načítavam tagy zo servera...'),
          ],
        ),
      );
    }

    if (_tagsError != null && _tags.isEmpty) {
      return _errorState(_tagsError!, _loadTags);
    }

    if (_tags.isEmpty) {
      return _emptyState(
        Icons.label_off_outlined,
        'Server momentálne neponúka žiadne tagy.',
        actionLabel: 'Načítať znova',
        onAction: _loadTags,
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Vyberte tag z DummyJSON API'),
              const SizedBox(height: 4),
              DropdownButton<String>(
                isExpanded: true,
                value: _selectedTag,
                hint: const Text('Zvoľte kategóriu'),
                items: _tags
                    .map(
                      (tag) => DropdownMenuItem<String>(
                        value: tag,
                        child: Text(tag),
                      ),
                    )
                    .toList(),
                onChanged: _chooseTag,
              ),
              if (widget.slowNetwork)
                const Text(
                  'Slow network je zapnutý (oneskorenie 0–3000 ms).',
                  style: TextStyle(fontSize: 12),
                ),
            ],
          ),
        ),
        Expanded(child: _buildTagResults()),
      ],
    );
  }

  Widget _buildTagResults() {
    if (_selectedTag == null) {
      return _emptyState(
        Icons.touch_app_outlined,
        'Vyberte tag a server načíta recepty z danej kategórie.',
      );
    }

    if (_resultsLoading && _recipes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Načítavam recepty podľa tagu...'),
          ],
        ),
      );
    }

    if (_resultsError != null && _recipes.isEmpty) {
      return _errorState(_resultsError!, _loadResults);
    }

    if (_recipes.isEmpty) {
      return _emptyState(
        Icons.inbox_outlined,
        'Pre tag „$_selectedTag“ sa nenašli žiadne recepty.',
        actionLabel: 'Načítať znova',
        onAction: _loadResults,
      );
    }

    return Column(
      children: [
        if (_resultsLoading) const LinearProgressIndicator(),
        if (_resultsError != null)
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(child: Text(_resultsError!)),
                  TextButton(
                    onPressed: _loadResults,
                    child: const Text('Skúsiť znova'),
                  ),
                ],
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Tag: $_selectedTag · ${_recipes.length} z $_total receptov',
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadResults,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _recipes.length,
              itemBuilder: (context, index) => _tagRecipeCard(_recipes[index]),
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
                onPressed: _resultsLoading || _skip == 0
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
                onPressed: _resultsLoading || _skip + _pageSize >= _total
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

  Widget _tagRecipeCard(Recipe recipe) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => widget.onOpenRecipe(context, recipe),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              SizedBox(width: 100, height: 100, child: _tagImage(recipe.image)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _tagDetail(Icons.public, recipe.cuisine),
                    _tagDetail(Icons.schedule, '${recipe.prepTimeMinutes} min'),
                    _tagDetail(
                      Icons.star_rounded,
                      recipe.rating.toStringAsFixed(1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorState(String message, VoidCallback retry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: retry,
              icon: const Icon(Icons.refresh),
              label: const Text('Skúsiť znova'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(
    IconData icon,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 12),
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Widget _tagImage(String url) {
  if (url.isEmpty) {
    return const Center(child: Icon(Icons.restaurant, size: 40));
  }
  return Image.network(
    url,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) =>
        const Center(child: Icon(Icons.broken_image_outlined, size: 40)),
  );
}

Widget _tagDetail(IconData icon, String value) {
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
