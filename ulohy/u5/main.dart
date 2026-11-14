import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const RecipeApp());
}

class _MouseDragScrollBehavior extends MaterialScrollBehavior {
  const _MouseDragScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        ...super.dragDevices,
        PointerDeviceKind.mouse,
      };
}

class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pasta Carbonara',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const _MouseDragScrollBehavior(),
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFBF9F5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFA75232),
          surface: const Color(0xFFFBF9F5),
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(color: Color(0xFFECE6DF)),
          ),
        ),
      ),
      home: const RecipeDetailPage(),
    );
  }
}

class RecipeDetailPage extends StatefulWidget {
  const RecipeDetailPage({super.key});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  // Shared state: the portions affect both ingredient presentations;
  // completed steps affect the method cards and their progress indicator.
  int _portions = 4;
  final Set<int> _readyIngredients = <int>{};
  final Set<int> _completedSteps = <int>{};

  // These amounts belong to the original recipe for 4 portions.
  static const _ingredients = <_Ingredient>[
    _Ingredient('Spaghetti', 400.0, 'g'),
    _Ingredient('Egg yolks', 4.0, 'pcs'),
    _Ingredient('Guanciale', 150.0, 'g'),
    _Ingredient('Pecorino', 80.0, 'g'),
    _Ingredient('Black pepper', null, 'to taste'),
    _Ingredient('Salt', null, 'to taste'),
  ];

  // Nutrition is always per serving and is NOT scaled with portions.
  static const _nutrition = <_Pair>[
    _Pair('Energy', '620 kcal'),
    _Pair('Protein', '27 g'),
    _Pair('Fat', '24 g'),
    _Pair('Carbohydrates', '71 g'),
  ];

  static const _preparationSteps = <String>[
    'Bring a large pot of salted water to the boil.',
    'Cut the guanciale into small strips.',
    'Whisk the egg yolks with grated pecorino and black pepper.',
  ];

  static const _cookingSteps = <String>[
    'Cook the spaghetti until al dente.',
    'Fry the guanciale in a dry pan until crispy.',
    'Take the pan off the heat and add the drained pasta.',
    'Pour in the egg mixture and stir quickly so the eggs do not scramble.',
    'Add pasta water little by little until the sauce is creamy.',
  ];

  int get _totalSteps =>
      _preparationSteps.length + _cookingSteps.length;

  void _setIngredientReady(int index, bool ready) {
    setState(() {
      if (ready) {
        _readyIngredients.add(index);
      } else {
        _readyIngredients.remove(index);
      }
    });
  }

  void _toggleStep(int index) {
    setState(() {
      if (!_completedSteps.add(index)) {
        _completedSteps.remove(index);
      }
    });
  }

  Future<void> _startCooking() async {
    final allSteps = <String>[
      ..._preparationSteps,
      ..._cookingSteps,
    ];
    final completedCount = await Navigator.of(context).push<int>(
      MaterialPageRoute<int>(
        builder: (context) => CookingModePage(
          steps: allSteps,
          portions: _portions,
        ),
      ),
    );

    if (!mounted) return;
    // The system back arrow returns null: leave all selections unchanged.
    if (completedCount == null) return;

    if (completedCount == allSteps.length) {
      setState(() {
        _completedSteps.addAll(
          Iterable<int>.generate(allSteps.length),
        );
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Enjoy your meal!')),
        );
    }
  }

  Future<void> _copyRecipeSummary() async {
    await Clipboard.setData(
      ClipboardData(text: 'Pasta Carbonara – $_portions portions'),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recipe summary copied!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    // Counts and the progress ratio are derived, not stored in State.
    final completedCount = _completedSteps.length;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            pinned: true,
            backgroundColor: const Color(0xFFFBF9F5),
            foregroundColor: const Color(0xFF2A2723),
            expandedHeight: 170,
            automaticallyImplyLeading: false,
            title: const Text('Pasta Carbonara'),
            actions: [
              const _FavoriteButton(),
              IconButton(
                tooltip: 'Copy recipe summary',
                icon: const Icon(Icons.ios_share_rounded),
                onPressed: _copyRecipeSummary,
              ),
              const SizedBox(width: 4),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(62),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                color: const Color(0xFFFBF9F5),
                alignment: Alignment.centerLeft,
                child: _PortionSelector(
                  portions: _portions,
                  onDecrease: _portions > 1
                      ? () => setState(() => _portions--)
                      : null,
                  onIncrease: _portions < 12
                      ? () => setState(() => _portions++)
                      : null,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                const _RecipeGallery(),
                const SizedBox(height: 28),
                const _SectionHeading(title: 'Ingredients'),
                _IngredientIcons(ingredients: _ingredients, portions: _portions),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: Text(
                    '${_readyIngredients.length} of ${_ingredients.length} ready',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF725845),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    child: Column(
                      children: [
                        for (var i = 0; i < _ingredients.length; i++) ...[
                          _IngredientRow(
                            item: _ingredients[i],
                            value: _ingredients[i].amountFor(_portions),
                            checked: _readyIngredients.contains(i),
                            onChanged: (ready) => _setIngredientReady(i, ready),
                          ),
                          if (i != _ingredients.length - 1)
                            const Divider(
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                              color: Color(0xFFF0EBE5),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const _SectionHeading(
                  title: 'Nutrition facts',
                  subtitle: 'per serving',
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const gap = 12.0;
                      final cardWidth = (constraints.maxWidth - gap) / 2;
                      return Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: [
                          for (final item in _nutrition)
                            SizedBox(
                              width: cardWidth,
                              child: _NutritionCard(item: item),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),
                _SectionHeading(
                  title: 'Method',
                  subtitle: '$completedCount / $_totalSteps',
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: completedCount / _totalSteps,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFECE6DF),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _MethodCard(
                        title: 'Preparation',
                        steps: _preparationSteps,
                        firstStepNumber: 1,
                        initiallyExpanded: true,
                        completedSteps: _completedSteps,
                        onStepTapped: _toggleStep,
                      ),
                      const SizedBox(height: 12),
                      _MethodCard(
                        title: 'Cooking',
                        steps: _cookingSteps,
                        firstStepNumber: 4,
                        initiallyExpanded: false,
                        completedSteps: _completedSteps,
                        onStepTapped: _toggleStep,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: const BoxDecoration(
          color: Color(0xFFFBF9F5),
          border: Border(top: BorderSide(color: Color(0xFFECE6DF))),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 54,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _startCooking,
              child: const Text(
                'Start cooking',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// This state is local: no other widget needs to know whether the recipe is liked.
class _FavoriteButton extends StatefulWidget {
  const _FavoriteButton();

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
      icon: Icon(
        _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        color: _isFavorite ? Theme.of(context).colorScheme.primary : null,
      ),
      onPressed: () => setState(() => _isFavorite = !_isFavorite),
    );
  }
}

// Presentational widget: portions live in RecipeDetailPage and are changed via callbacks.
class _PortionSelector extends StatelessWidget {
  const _PortionSelector({
    required this.portions,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int portions;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          tooltip: 'Decrease portions',
          onPressed: onDecrease,
          icon: const Icon(Icons.remove_rounded),
        ),
        SizedBox(
          width: 112,
          child: Text(
            '$portions portions',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Increase portions',
          onPressed: onIncrease,
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    );
  }
}

class _Ingredient {
  const _Ingredient(this.label, this.amountForFour, this.unit);

  final String label;
  final double? amountForFour;
  final String unit;

  String amountFor(int portions) {
    if (amountForFour == null) return unit; // e.g. "to taste"

    final scaledAmount = amountForFour! * portions / 4;
    final displayedAmount = scaledAmount == scaledAmount.truncateToDouble()
        ? scaledAmount.toStringAsFixed(0)
        : scaledAmount.toStringAsFixed(1);
    return '$displayedAmount $unit';
  }
}

class _IngredientIcons extends StatelessWidget {
  const _IngredientIcons({required this.ingredients, required this.portions});

  final List<_Ingredient> ingredients;
  final int portions;

  static const _icons = <IconData>[
    Icons.ramen_dining_rounded,
    Icons.egg_alt_rounded,
    Icons.lunch_dining_rounded,
    Icons.local_pizza_rounded,
    Icons.grain_rounded,
    Icons.water_drop_outlined,
  ];
  static const _backgrounds = <Color>[
    Color(0xFFFFE8CE),
    Color(0xFFFFF1BD),
    Color(0xFFF9D6CA),
    Color(0xFFFFE6AD),
    Color(0xFFE8E4DF),
    Color(0xFFDDEAEF),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Text(
            'Swipe to see all ${ingredients.length} ingredients  →',
            style: const TextStyle(fontSize: 12, color: Color(0xFF77716B)),
          ),
        ),
        SizedBox(
          height: 144,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: ingredients.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return _IngredientIconCard(
                item: ingredients[index],
                value: ingredients[index].amountFor(portions),
                icon: _icons[index],
                background: _backgrounds[index],
              );
            },
          ),
        ),
      ],
    );
  }
}

// The gallery page index and its controller remain inside the gallery widget.
class _RecipeGallery extends StatefulWidget {
  const _RecipeGallery();

  @override
  State<_RecipeGallery> createState() => _RecipeGalleryState();
}

class _RecipeGalleryState extends State<_RecipeGallery> {
  final PageController _pageController = PageController();
  int _selectedPhoto = 0;

  static const _photos = <_RecipePhoto>[
    _RecipePhoto(Color(0xFFE3AC72), Icons.restaurant),
    _RecipePhoto(Color(0xFF9AB29C), Icons.ramen_dining),
    _RecipePhoto(Color(0xFFD69F8D), Icons.dinner_dining),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectPhoto(int index) {
    if (index < 0 || index >= _photos.length) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            height: 230,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.horizontal,
                    physics: const PageScrollPhysics(),
                    itemCount: _photos.length,
                    onPageChanged: (index) {
                      setState(() => _selectedPhoto = index);
                    },
                    itemBuilder: (context, index) {
                      final photo = _photos[index];
                      return ColoredBox(
                        color: photo.color,
                        child: Center(
                          child: Icon(
                            photo.icon,
                            size: 100,
                            color: Colors.white.withValues(alpha: 0.9),
                            semanticLabel: 'Recipe photo ${index + 1}',
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 8,
                    child: Center(
                      child: _GalleryArrow(
                        icon: Icons.chevron_left_rounded,
                        enabled: _selectedPhoto > 0,
                        onPressed: () => _selectPhoto(_selectedPhoto - 1),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 8,
                    child: Center(
                      child: _GalleryArrow(
                        icon: Icons.chevron_right_rounded,
                        enabled: _selectedPhoto < _photos.length - 1,
                        onPressed: () => _selectPhoto(_selectedPhoto + 1),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: Text(
                          '${_selectedPhoto + 1} / ${_photos.length}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 14,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < _photos.length; i++)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            height: 7,
                            width: i == _selectedPhoto ? 22 : 7,
                            decoration: BoxDecoration(
                              color: i == _selectedPhoto
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.48),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Swipe left or right to see all 3 pictures',
          style: TextStyle(color: Color(0xFF77716B), fontSize: 12),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 66,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _photos.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final photo = _photos[index];
              final selected = index == _selectedPhoto;
              return Semantics(
                button: true,
                selected: selected,
                label: 'Show recipe photo ${index + 1}',
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _selectPhoto(index),
                  child: Container(
                    width: 86,
                    decoration: BoxDecoration(
                      color: photo.color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF773E26)
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: Icon(photo.icon, color: Colors.white, size: 30),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _GalleryArrow extends StatelessWidget {
  const _GalleryArrow({
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: enabled ? 0.38 : 0.15),
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icon, color: enabled ? Colors.white : Colors.white54),
        onPressed: enabled ? onPressed : null,
      ),
    );
  }
}

class _RecipePhoto {
  const _RecipePhoto(this.color, this.icon);

  final Color color;
  final IconData icon;
}

class _Pair {
  const _Pair(this.label, this.value);

  final String label;
  final String value;
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2A2723),
                  ),
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF77716B),
                  ),
            ),
        ],
      ),
    );
  }
}

class _IngredientIconCard extends StatelessWidget {
  const _IngredientIconCard({
    required this.item,
    required this.value,
    required this.icon,
    required this.background,
  });

  final _Ingredient item;
  final String value;
  final IconData icon;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${item.label}, $value',
      child: Container(
        width: 124,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFECE6DF)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 54,
              width: 54,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 29, color: const Color(0xFF704831)),
            ),
            const SizedBox(height: 8),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Color(0xFF77716B)),
            ),
          ],
        ),
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({
    required this.item,
    required this.value,
    required this.checked,
    required this.onChanged,
  });

  final _Ingredient item;
  final String value;
  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!checked),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Checkbox(
              value: checked,
              onChanged: (value) => onChanged(value ?? false),
              semanticLabel: item.label,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  decoration: checked ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF725845),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NutritionCard extends StatelessWidget {
  const _NutritionCard({required this.item});

  final _Pair item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF77716B)),
            ),
            const SizedBox(height: 7),
            Text(
              item.value,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2A2723),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.title,
    required this.steps,
    required this.firstStepNumber,
    required this.initiallyExpanded,
    required this.completedSteps,
    required this.onStepTapped,
  });

  final String title;
  final List<String> steps;
  final int firstStepNumber;
  final bool initiallyExpanded;
  final Set<int> completedSteps;
  final ValueChanged<int> onStepTapped;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        key: PageStorageKey<String>(title),
        initiallyExpanded: initiallyExpanded,
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        collapsedIconColor: const Color(0xFF725845),
        iconColor: const Color(0xFF725845),
        shape: const Border(),
        collapsedShape: const Border(),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        children: [
          const Divider(color: Color(0xFFF0EBE5)),
          for (var index = 0; index < steps.length; index++)
            _MethodStep(
              number: firstStepNumber + index,
              text: steps[index],
              completed: completedSteps.contains(firstStepNumber + index - 1),
              onTap: () => onStepTapped(firstStepNumber + index - 1),
            ),
        ],
      ),
    );
  }
}

class _MethodStep extends StatelessWidget {
  const _MethodStep({
    required this.number,
    required this.text,
    required this.completed,
    required this.onTap,
  });

  final int number;
  final String text;
  final bool completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      checked: completed,
      label: 'Step $number: $text',
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              completed
                  ? const Icon(
                      Icons.check_circle_rounded,
                      size: 28,
                      color: Color(0xFF388447),
                    )
                  : Container(
                      height: 28,
                      width: 28,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF4E5DC),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$number',
                        style: const TextStyle(
                          color: Color(0xFF8A482C),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: completed ? const Color(0xFF77716B) : null,
                      decoration: completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Receives a copy of the recipe data; it owns only its current step index.
// System back returns null, while Finish returns the number of finished steps.
class CookingModePage extends StatefulWidget {
  const CookingModePage({
    super.key,
    required this.steps,
    required this.portions,
  }) : assert(steps.length > 0);

  final List<String> steps;
  final int portions;

  @override
  State<CookingModePage> createState() => _CookingModePageState();
}

class _CookingModePageState extends State<CookingModePage> {
  int _currentStep = 0;

  void _nextOrFinish() {
    if (_currentStep == widget.steps.length - 1) {
      Navigator.of(context).pop(widget.steps.length);
    } else {
      setState(() => _currentStep++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastStep = _currentStep == widget.steps.length - 1;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Cooking mode')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${widget.portions} portions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (_currentStep + 1) / widget.steps.length,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Step ${_currentStep + 1} of ${widget.steps.length}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 22),
                            Text(
                              widget.steps[_currentStep],
                              style: theme.textTheme.headlineSmall?.copyWith(
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _currentStep > 0
                          ? () => setState(() => _currentStep--)
                          : null,
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _nextOrFinish,
                      child: Text(isLastStep ? 'Finish' : 'Next'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
