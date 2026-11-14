# U4 – Implementácia obrazovky

Na cvičení uvidíte obrázky obrazovky mobilnej aplikácie (celá obrazovka a zaskrolovaný stav).
Úlohou je čo najvernejšie ju implementovať vo Flutteri.

- iba **layout a scrolovanie** – dáta môžu byť priamo v kóde, obrázky stačí nahradiť farebnou
  plochou s ikonou, tlačidlá môžu mať prázdne `onPressed`,
- môžete použiť **AI nástroje** – odovzdajte aj **históriu promptov**,
- odovzdanie cez **tento priečinok** vo vašom repozitári.

## Sledujte

- čo sa pri scrolle **zmenší** a čo zostane **pripnuté**,
- čo sa dá potiahnuť **do strany** alebo **rozbaliť**,
- čo sa **opakuje** → vlastný widget.

## Skupina 1 – Detail receptu

- nový prvok: **`ExpansionTile`**
- ďalej: `CustomScrollView`, `SliverAppBar.large`, `PageView`, vodorovný `ListView`, `Card`,
  `Row` / `Column`

## Skupina 2 – Kategória v e-shope

- nové prvky: **`SliverAppBar`** (`pinned`, `bottom`), **`SliverMainAxisGroup`** +
  **`SliverPersistentHeader`**
- ďalej: `CustomScrollView`, `PageView`, vodorovný `ListView`, `SliverGrid`,
  `Stack` + `Positioned`, `Badge`, `NavigationBar`

## Texty z obrazoviek

Aby ste ich nemuseli opisovať z obrázkov – texty a dáta môžete skopírovať.

### Skupina 1 – Detail receptu

- **Názov:** Pasta Carbonara
- **Fotky:** 3 farebné plochy s ikonou jedla
- **Ingredients** (názov – množstvo):
  - Spaghetti – 400 g
  - Egg yolks – 4 pcs
  - Guanciale – 150 g
  - Pecorino – 80 g
  - Black pepper – to taste
  - Salt – to taste
- **Nutrition facts** – podnadpis *per serving*:
  - Energy – 620 kcal
  - Protein – 27 g
  - Fat – 24 g
  - Carbohydrates – 71 g
- **Method**
  - **Preparation**
    1. Bring a large pot of salted water to the boil.
    2. Cut the guanciale into small strips.
    3. Whisk the egg yolks with grated pecorino and black pepper.
  - **Cooking**
    4. Cook the spaghetti until al dente.
    5. Fry the guanciale in a dry pan until crispy.
    6. Take the pan off the heat and add the drained pasta.
    7. Pour in the egg mixture and stir quickly so the eggs do not scramble.
    8. Add pasta water little by little until the sauce is creamy.
- **Tlačidlo dole:** Start cooking

### Skupina 2 – Kategória v e-shope

- **Názov:** Running shoes – ikona košíka s odznakom *2*
- **Vyhľadávanie:** Search shoes (ikona vyhľadávania vľavo, ikona filtra vpravo)
- **Bannery** (nadpis – text):
  - Autumn sale – Up to -40 % on trail shoes
  - Free delivery – On all orders over 50 €
  - New collection – Lightweight racing shoes
- **Značky:** Asics, Brooks, Hoka, Nike, On, Saucony, Adidas (v krúžku prvé písmeno)
- **Sekcie** (vpravo pri nadpise počet, napr. *2 items*):
  - **New arrivals**
    - Cloud Runner 5 – 139.90 €
    - Trail Hawk GTX – 159.00 €
  - **Best sellers**
    - Daily Trainer 3 – 109.90 €
    - Road Glide – 129.00 €
  - **Sale** (nová cena – pôvodná preškrtnutá cena – odznak zľavy)
    - Sprint Racer – 79.90 € – ~~119.90 €~~ – -33 %
    - Forest Path – 89.00 € – ~~129.00 €~~ – -31 %
    - City Jogger – 59.90 € – ~~89.90 €~~ – -33 %
- **Spodná navigácia:** Home, Categories (vybraná), Cart (odznak *2*), Profile

## Odovzdanie

Do tohto priečinka uložte:

- dart súbor(y) s implementáciou (`lib/`) – nie celý priečinok `build/`,
- screenshot(y) vášho výsledku,
- históriu promptov (stačí textový súbor alebo export z nástroja).
