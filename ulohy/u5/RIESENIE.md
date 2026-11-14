# RIEŠENIE – U5, skupina 1
- `_FavoriteButton` vlastní lokálny `bool _isFavorite`, pretože srdiečko nepotrebuje ovplyvňovať iné widgety.
- `_RecipeGallery` vlastní `_selectedPhoto` a `PageController`; controller vytvorí raz a uvoľní v `dispose()`.
- `RecipeDetailPage` vlastní `_portions`, `_readyIngredients` a `_completedSteps`: hodnoty zdieľa s počítadlom, ingredienciami a postupom cez konštruktory a callbacky.
- Množstvá (`amountFor`), počet pripravených ingrediencií a priebeh postupu sa vždy počítajú zo stavu, neukladajú sa zvlášť; výživové hodnoty zostávajú na porciu.
- `CookingModePage` vlastní iba `_currentStep`, dostáva kroky a porcie cez `Navigator.push`; `Finish` vráti počet krokov cez `pop`, späť vráti `null` a po `await` sa kontroluje `mounted`.
