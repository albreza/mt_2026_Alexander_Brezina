import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

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
      // In DartPad (web), dragging with a mouse works as well as touch swipes.
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
  final PageController _pageController = PageController();
  int _selectedPhoto = 0;

  static const _photos = <_RecipePhoto>[
    _RecipePhoto(Color(0xFFE3AC72), Icons.restaurant),
    _RecipePhoto(Color(0xFF9AB29C), Icons.ramen_dining),
    _RecipePhoto(Color(0xFFD69F8D), Icons.dinner_dining),
  ];

  static const _ingredients = <_Pair>[
    _Pair('Spaghetti', '400 g'),
    _Pair('Egg yolks', '4 pcs'),
    _Pair('Guanciale', '150 g'),
    _Pair('Pecorino', '80 g'),
    _Pair('Black pepper', 'to taste'),
    _Pair('Salt', 'to taste'),
  ];

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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectPhoto(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      // The main content scrolls; the CTA below remains visible.
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            pinned: true,
            backgroundColor: const Color(0xFFFBF9F5),
            foregroundColor: const Color(0xFF2A2723),
            expandedHeight: 160,
            automaticallyImplyLeading: false,
            title: const Text('Pasta Carbonara'),
            actions: [
              IconButton(
                tooltip: 'Favorite',
                icon: const Icon(Icons.favorite_border_rounded),
                onPressed: () {},
              ),
              IconButton(
                tooltip: 'Share',
                icon: const Icon(Icons.ios_share_rounded),
                onPressed: () {},
              ),
              const SizedBox(width: 4),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGallery(),
                const SizedBox(height: 28),
                const _SectionHeading(title: 'Ingredients'),
                // Swipeable ingredient icons above the original full list.
                _buildIngredientIcons(),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    child: Column(
                      children: [
                        for (var i = 0; i < _ingredients.length; i++) ...[
                          _IngredientRow(item: _ingredients[i]),
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
                const _SectionHeading(title: 'Method'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _MethodCard(
                        title: 'Preparation',
                        steps: _preparationSteps,
                        firstStepNumber: 1,
                        initiallyExpanded: true,
                      ),
                      const SizedBox(height: 12),
                      _MethodCard(
                        title: 'Cooking',
                        steps: _cookingSteps,
                        firstStepNumber: 4,
                        initiallyExpanded: false,
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
              onPressed: () {},
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

  Widget _buildIngredientIcons() {
    const icons = <IconData>[
      Icons.ramen_dining_rounded, // Spaghetti
      Icons.egg_alt_rounded, // Egg yolks
      Icons.lunch_dining_rounded, // Guanciale
      Icons.local_pizza_rounded, // Pecorino
      Icons.grain_rounded, // Black pepper
      Icons.water_drop_outlined, // Salt
    ];
    const backgrounds = <Color>[
      Color(0xFFFFE8CE),
      Color(0xFFFFF1BD),
      Color(0xFFF9D6CA),
      Color(0xFFFFE6AD),
      Color(0xFFE8E4DF),
      Color(0xFFDDEAEF),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Text(
            'Swipe to see all 6 ingredients  →',
            style: TextStyle(fontSize: 12, color: Color(0xFF77716B)),
          ),
        ),
        SizedBox(
          height: 144,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _ingredients.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return _IngredientIconCard(
                item: _ingredients[index],
                icon: icons[index],
                background: backgrounds[index],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGallery() {
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
                    // Swipe horizontally to move between all three photos.
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
                  // Alternative to swiping: arrows to navigate the photos.
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
        // A horizontal ListView: swipe thumbnails or tap to change the PageView.
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
    required this.icon,
    required this.background,
  });

  final _Pair item;
  final IconData icon;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${item.label}, ${item.value}',
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
              item.value,
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
  const _IngredientRow({required this.item});

  final _Pair item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            item.value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF725845),
            ),
          ),
        ],
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
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF77716B),
              ),
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
  });

  final String title;
  final List<String> steps;
  final int firstStepNumber;
  final bool initiallyExpanded;

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
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        children: [
          const Divider(color: Color(0xFFF0EBE5)),
          for (var index = 0; index < steps.length; index++)
            _MethodStep(number: firstStepNumber + index, text: steps[index]),
        ],
      ),
    );
  }
}

class _MethodStep extends StatelessWidget {
  const _MethodStep({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
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
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
