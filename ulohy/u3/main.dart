import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

// Model miesta (rozšírenie z kroku 9).
class Place {
  const Place({
    required this.name,
    required this.location,
    required this.description,
    required this.imageUrl,
    required this.imageCaption,
  });

  final String name;
  final String location;
  final String description;
  final String imageUrl;
  final String imageCaption;
}

const Place oeschinenLake = Place(
  name: 'Oeschinen Lake Campground',
  location: 'Kandersteg, Switzerland',
  description:
      'Lake Oeschinen lies at the foot of the Blüemlisalp in the '
      'Bernese Alps. Situated 1,578 meters above sea level, it '
      'is one of the larger Alpine Lakes. A gondola ride from '
      'Kandersteg, followed by a half-hour walk through pastures '
      'and pine forest, leads you to the lake, which warms to 20 '
      'degrees Celsius in the summer. Activities enjoyed here '
      'include rowing, and riding the summer toboggan run.',
  imageUrl:
      'https://raw.githubusercontent.com/flutter/website/main/'
      'examples/layout/lakes/step5/images/lake.jpg',
  imageCaption: 'Oeschinen Lake',
);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    const seedColor = Colors.teal;

    return MaterialApp(
      title: 'Flutter layout demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _themeMode,
      home: PlaceDetailPage(
        place: oeschinenLake,
        onThemeChanged: (mode) => setState(() => _themeMode = mode),
      ),
    );
  }
}

// Obrazovka prijima data cez Place, nie cez natvrdo zapisane texty.
class PlaceDetailPage extends StatelessWidget {
  const PlaceDetailPage({
    super.key,
    required this.place,
    required this.onThemeChanged,
  });

  final Place place;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter layout demo'),
        actions: [
          // Volitelne prepinanie temy, systemovy rezim je predvoleny.
          PopupMenuButton<ThemeMode>(
            tooltip: 'Zmeniť vzhľad',
            icon: const Icon(Icons.brightness_6_outlined),
            onSelected: onThemeChanged,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: ThemeMode.system,
                child: Text('Podľa systému'),
              ),
              PopupMenuItem(
                value: ThemeMode.light,
                child: Text('Svetlý režim'),
              ),
              PopupMenuItem(
                value: ThemeMode.dark,
                child: Text('Tmavý režim'),
              ),
            ],
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Rozšírenie: pri šírke >= 600 je obrázok vľavo, obsah vpravo.
          final isWide = constraints.maxWidth >= 600;

          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ImageSection(
                              imageUrl: place.imageUrl,
                              caption: place.imageCaption,
                              height: 400,
                            ),
                          ),
                          Expanded(child: _DetailSections(place: place)),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ImageSection(
                            imageUrl: place.imageUrl,
                            caption: place.imageCaption,
                            height: 240,
                          ),
                          _DetailSections(place: place),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DetailSections extends StatelessWidget {
  const _DetailSections({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TitleSection(name: place.name, location: place.location),
        const ButtonSection(),
        TextSection(description: place.description),
      ],
    );
  }
}

// Sekcia 1: fotka s názvom cez Stack a Positioned (rozšírenie).
class ImageSection extends StatelessWidget {
  const ImageSection({
    super.key,
    required this.imageUrl,
    required this.caption,
    required this.height,
  });

  final String imageUrl;
  final String caption;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            semanticLabel: 'Fotografia jazera Oeschinen v Alpách',
            errorBuilder: (context, error, stackTrace) => ColoredBox(
              color: colors.surfaceContainerHighest,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.landscape_outlined,
                        size: 56, color: colors.onSurfaceVariant),
                    const SizedBox(height: 8),
                    Text('Obrázok sa nepodarilo načítať',
                        style: text.bodyMedium),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.inverseSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                child: Text(
                  caption,
                  style: text.titleSmall?.copyWith(
                    color: colors.onInverseSurface,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Sekcia 2: nadpis, lokalita a interaktivne hodnotenie.
class TitleSection extends StatelessWidget {
  const TitleSection({
    super.key,
    required this.name,
    required this.location,
  });

  final String name;
  final String location;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  location,
                  style: text.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const FavoriteWidget(),
        ],
      ),
    );
  }
}

class FavoriteWidget extends StatefulWidget {
  const FavoriteWidget({super.key});

  @override
  State<FavoriteWidget> createState() => _FavoriteWidgetState();
}

class _FavoriteWidgetState extends State<FavoriteWidget> {
  bool _isFavorited = true;
  int _count = 41;

  void _toggleFavorite() {
    setState(() {
      _isFavorited = !_isFavorited;
      _count += _isFavorited ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: _isFavorited ? 'Odobrať z obľúbených' : 'Pridať do obľúbených',
          onPressed: _toggleFavorite,
          icon: Icon(_isFavorited ? Icons.star : Icons.star_border),
          color: Theme.of(context).colorScheme.primary,
        ),
        Text('$_count', style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

// Sekcia 3: tri skutocne klikatelne tlacidla so SnackBar (rozsirenie).
class ButtonSection extends StatelessWidget {
  const ButtonSection({super.key});

  void _showMessage(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ButtonWithText(
            icon: Icons.call,
            label: 'CALL',
            onTap: () => _showMessage(context, 'Volanie: Oeschinen Lake Campground'),
          ),
          ButtonWithText(
            icon: Icons.near_me,
            label: 'ROUTE',
            onTap: () => _showMessage(context, 'Trasa: Kandersteg, Switzerland'),
          ),
          ButtonWithText(
            icon: Icons.share,
            label: 'SHARE',
            onTap: () => _showMessage(context, 'Zdieľanie miesta: Oeschinen Lake'),
          ),
        ],
      ),
    );
  }
}

class ButtonWithText extends StatelessWidget {
  const ButtonWithText({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: colors.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: text.labelMedium?.copyWith(color: colors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

// Sekcia 4: dlhy text, ktory sa automaticky zalamuje.
class TextSection extends StatelessWidget {
  const TextSection({super.key, required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        description,
        softWrap: true,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}
