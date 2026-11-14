# U5 – Interaktívna obrazovka

Oživte obrazovku z úlohy U4 (rovnaká skupina). Layout už máte – teraz pridajte **stav**:
ťuknutia, vstupy a navigáciu na ďalšiu obrazovku.

- vychádzajte zo svojho riešenia U4 (ak nie je hotové, dokončite najprv layout),
- môžete použiť **AI nástroje** – odovzdajte aj **históriu promptov**,
- odovzdanie cez **tento priečinok** vo vašom repozitári.

## Požiadavky (obe skupiny)

- **lokálny stav** – aspoň jeden widget, ktorý si stav spravuje sám (napr. srdiečko, rozbalenie),
- **zdvihnutý stav** – spoločný stav u rodiča, dáta dole cez konštruktor, zmeny hore cez callback
  (`ValueChanged<T>`, `VoidCallback`),
- **kontrolovaný vstup** – `Checkbox`, `FilterChip`, `TextField` s controllerom a pod.,
- **navigácia** – `Navigator.push` s dátami na novú obrazovku a **výsledok späť** cez `pop`,
- stav **čo najnižšie** v strome – nie celá aplikácia v jednom `StatefulWidget`,
- čo sa dá **vypočítať** zo stavu (súčty, filtrované zoznamy, priebeh), neukladajte do stavu,
- controllery vytvorte **raz** a uvoľnite v `dispose()`, po `await` skontrolujte `mounted`.

Dáta môžu zostať priamo v kóde. Stav sa po reštarte aplikácie nemusí uchovať.

## Skupina 1 – Detail receptu

1. **Obľúbené** – srdiečko v `SliverAppBar` prepína `favorite_border` ↔ `favorite`.
2. **Počet porcií** – v hlavičke `−  4 portions  +` (rozsah 1–12). Množstvá v *Ingredients*
   sa **prepočítajú** (pôvodné hodnoty sú pre 4 porcie, *to taste* sa nemení). Aj *Nutrition facts*
   zostávajú *per serving*.
3. **Ingrediencie** – každú možno odškrtnúť (`CheckboxListTile` alebo `Checkbox` v riadku);
   nad zoznamom text *3 of 6 ready*.
4. **Kroky postupu** – ťuknutím sa krok označí ako hotový (preškrtnutý text, ikona `check_circle`).
   Pri nadpise *Method* `LinearProgressIndicator` a text *3 / 8*.
5. **Start cooking** → nová obrazovka **Cooking mode**:
   - dostane zoznam krokov a počet porcií,
   - zobrazí **jeden krok** naraz (*Step 4 of 8*), tlačidlá *Back* / *Next*, na poslednom kroku *Finish*,
   - *Finish* vráti počet dokončených krokov; na detaile sa všetky kroky označia ako hotové
     a zobrazí sa `SnackBar` *Enjoy your meal!*,
   - šípka späť bez dokončenia nemení nič.

## Skupina 2 – Kategória v e-shope

1. **Obľúbené** – srdiečko na karte produktu prepína `favorite_border` ↔ `favorite`.
2. **Košík** – tlačidlo na karte (alebo ťuknutie na ikonu košíka) pridá produkt. Počet kusov
   v košíku sa zobrazuje v odznaku **v `AppBar` aj v `NavigationBar`** (jeden zdroj pravdy,
   na začiatku 0).
3. **Filter značiek** – kruhy so značkami fungujú ako prepínače (vybraná značka je zvýraznená,
   viac značiek naraz). Zobrazia sa len produkty vybraných značiek; nič nevybraté = všetko.
   Značky priraďte produktom podľa seba.
4. **Vyhľadávanie** – pole *Search shoes* filtruje produkty podľa názvu (bez ohľadu na veľkosť
   písmen); počty *N items* pri sekciách sa prepočítajú, prázdna sekcia sa nezobrazí.
5. **Detail produktu** – ťuknutie na kartu otvorí novú obrazovku:
   - dostane produkt (názov, cena, prípadne zľava),
   - výber veľkosti (`SegmentedButton` alebo `ChoiceChip`: 40–45) a množstvo `− 1 +`,
   - *Add to cart* je zakázané, kým nie je vybraná veľkosť; vráti zvolené množstvo,
   - na kategórii sa počet v košíku zvýši a zobrazí sa `SnackBar` *Added 2 × Road Glide*.
6. **NavigationBar** – prepínanie záložiek (iné záložky môžu byť len text s názvom).

## Odovzdanie

Do tohto priečinka uložte:

- dart súbor(y) s implementáciou (`lib/`) – nie celý priečinok `build/`,
- krátke video alebo niekoľko screenshotov, na ktorých je vidieť každú interakciu,
- históriu promptov (stačí textový súbor alebo export z nástroja),
- v krátkom `RIESENIE.md` (3–6 riadkov): **kde je ktorý stav** (ktorý widget ho vlastní) a prečo.
