# Projekt (40 %)

**Návrh a implementácia komplexnej mobilnej aplikácie** - nadväzuje na úlohy U1 a U2.

- Každý pracuje samostatne.
- Dôraz na **mobilný aspekt** - aplikácia využíva možnosti zariadenia (kamera, poloha, senzory, notifikácie, offline ...).
- **Backend / cloud** (server, autentifikácia, dáta na serveri) nie je povinný - bez neho sa však očakáva
  viac práce na zariadení (pozri minimálne požiadavky).
- UI navrhnuté v nástroji na návrh rozhrania (pozri U2).
- Technológia: **Flutter**. Iná technológia (Kotlin, Swift, React Native ...) je možná po dohode s vyučujúcim.

## Minimálne požiadavky

**Pre všetky projekty**

- aspoň **5 obrazoviek** s navigáciou podľa návrhu z U2 (zmeny oproti návrhu sú v poriadku, popíšte ich),
- aspoň jedna **funkcia zariadenia** skutočne použitá v riešení - poloha, kamera, notifikácie, senzory, mikrofón,
  offline režim ...,
- **dáta prežijú reštart aplikácie** - na serveri alebo v zariadení (SQLite, Hive, súbory ...),
- obrazovky, ktoré načítavajú dáta (zo servera, z API, zo súborov), zobrazujú stav **načítania**, **chyby**
  a **prázdneho** zoznamu,
- konfiguračné kľúče sa načítavajú mimo kódu (`--dart-define-from-file`, `.env` ...) - v repozitári je iba vzor,
  napr. `env.example`,
- **aplikácia sa dá spustiť podľa `code/app/LAUNCH.md`** po čerstvom naklonovaní repozitára. Overte si to:
  naklonujte repozitár do iného priečinka a postupujte presne podľa vlastného návodu. Ak aplikácia potrebuje
  server, musí sa dať tiež spustiť podľa návodu, alebo ideálne stále bežať.

**S backendom / cloudom**

- **prihlásenie používateľa** a dáta uložené na serveri (Firebase, Supabase, vlastný server ...),
- **pravidlá prístupu k dátam v repozitári** - napr. `firestore.rules`, `storage.rules`, prípadne autorizácia
  vo vlastnom backende. Pravidlá nastavené iba v konzole sa nedajú skontrolovať, a teda ani ohodnotiť -
  exportujte ich do repozitára.

**Bez backendu** - očakáva sa viac práce na zariadení:

- dáta uložené v zariadení (lokálna databáza alebo súbory), nielen jednoduché nastavenia,
- **viac funkcií zariadenia** (aspoň dve až tri) alebo jedna využitá do hĺbky (napr. spracovanie obrazu
  alebo zvuku, senzory v reálnom čase, mapa so záznamom trasy), **alebo** rozsiahlejšia aplikácia
  (približne 10 obrazoviek).

Načítanie dát z verejného API (počasie, recepty ...) je v poriadku, za backend sa však nepovažuje.

## Štruktúra

| Priečinok / súbor | Obsah |
|---|---|
| `code/app/` | mobilná aplikácia (Flutter projekt) |
| `code/app/LAUNCH.md` | ako aplikáciu spustiť (napr. 3-5 riadkov) |
| `code/backend/` | serverová časť a **pravidlá prístupu** (`firestore.rules`, Cloud Functions ...), ak ju máte |
| `code/...` | ďalšie časti riešenia, ak sú - napr. `code/webapp/`, `code/scripts/` |
| `docs/` | dokumentácia projektu |
| `.github/workflows/` | konfigurácia CI, ak ju máte (v koreni repozitára) |

Súbory `README.md` **nevytvárajte ani nemeňte** - patria šablóne. Vlastné súbory pomenujte inak
(`LAUNCH.md`, `docs/dokumentacia.md` ...). Súbor `README.md`, ktorý vytvorí `flutter create`, môžete
v `code/app/` nechať bez zmeny alebo zmazať.

Do repozitára nepatria `build/`, `.dart_tool/`, `local.properties` ani kľúče -
ponechajte `.gitignore`, ktorý vytvorí `flutter create` (prípadne `.gitignore` podľa typu projektu).

## Práca s repozitárom

- Commitujte a pushujte **priebežne počas semestra**. Očakáva sa práca aspoň v **štyroch rôznych týždňoch**;
  projekt odovzdaný jedným alebo dvoma commitmi na konci semestra túto požiadavku nespĺňa.
- Históriu **neprepisujte** (`push --force`, `rebase` už odoslaných commitov, zmazanie a nahratie repozitára
  nanovo). Stav v kontrolných bodoch sa posudzuje podľa záznamu na serveri, nie podľa dátumov v commitoch.
- Píšte zmysluplné správy ku commitom. Stačí jedna veta o tom, čo sa zmenilo - môže ju navrhnúť aj AI.

## Kľúče a tajomstvá (keys, secrets)

Konfiguračné kľúče (Firebase, API kľúče, `.env`, servisné účty) **necommitujte** - v repozitári nechajte iba
`env.example` so zástupnými hodnotami a v dokumentácii uveďte, ako kľúče získať.

Ak sa kľúč do repozitára predsa dostane, **nahláste to a kľúč zneplatnite**. Samotný incident hodnotenie
neznižuje, jeho zamlčanie áno. Platí to aj pre kľúč, ktorý už nie je v poslednej verzii, ale zostal v histórii.

## Dokumentácia

Dokumentáciu uložte do `docs/`, formu si zvoľte sami (Markdown, PDF ...). Z dokumentácie by malo byť jasné:

- **názov a stručný opis** projektu - platforma, krátky výstižný opis ako v App Store / Google Play,
- **architektúra riešenia** - z akých častí sa skladá (aplikácia, lokálne úložisko, server, databáza,
  externé API, cloud ...), ideálne s diagramom,
- **návrh obrazoviek** - odkaz na návrh (Figma, Stitch, Penpot ...) a zmeny oproti U2,
- **popis obrazoviek a funkcionality** - napr. user stories alebo use cases,
- **screenshoty** implementovanej aplikácie,
- **použité technológie a balíčky** a odkaz na `code/app/LAUNCH.md`,
- **zhodnotenie** - čo sa podarilo, čo nie, možné rozšírenia,
- **použitie LLM nástrojov** - pozri nasledujúcu časť.

### Použitie LLM nástrojov

Použitie LLM nástrojov je povolené a očakávané. Do dokumentácie doplňte tabuľku v tomto tvare:

| Časť projektu | Nástroj a model | Spôsob použitia | Podiel AI |
|---|---|---|---|
| návrh a architektúra | | generovanie / ladenie / vysvetľovanie / review | žiadny / čiastočný / prevažný |
| obrazovky a UI | | | |
| dáta a backend | | | |
| funkcia zariadenia | | | |
| dokumentácia | | | |
| ladenie chýb | | | |

- **Nástroj a model** uvádzajte konkrétne (napr. „Claude Code, Sonnet 4.6“, nie „AI asistent“).
- Odovzdajte **históriu promptov** - iba to, čo ste do nástroja písali **vy**, odpovede AI netreba.
  Stačí textový súbor (napr. `docs/prompty.md`) s dátumom a nástrojom pri každom prompte; ak nástroj vie
  históriu exportovať, môžete odovzdať export.
- Konfiguračné súbory agentov (`CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `.cursorrules`, `.claude/` ...)
  **commitujte**. Sú súčasťou práce, nie niečím, čo treba skrývať.
- Doplňte krátke zhodnotenie: kde vám nástroj pomohol, kde navrhol nesprávne riešenie a ako ste to zistili.

Odovzdaný repozitár sa porovnáva s touto tabuľkou a s históriou promptov. Nejde o hľadanie chýb - cieľom je,
aby popis práce zodpovedal tomu, čo je v repozitári vidieť.

## Priebeh a kontrolné body

Na cvičení ukážete aktuálny stav - **podľa repozitára, nie podľa lokálnej kópie**.

| Kedy | Čo má byť hotové |
|---|---|
| **Názov** - do 27. 11. | finálny názov projektu v `student.txt`, v `docs/` prvotný opis a architektúra |
| **Aplikácia** - do 8. 12. | Flutter projekt v `code/app/`, funkčná navigácia medzi obrazovkami, upravené `docs/`, `.gitignore` a `env.example` |
| **Finál** - do 18. 12. | kompletný zdrojový kód a dokumentácia so screenshotmi, tabuľkou použitia LLM a históriou promptov |
| **Obhajoba** - online | prezentácia a demo počas skúškového obdobia |

Hodnotí sa stav repozitára v termíne odovzdania (posledný commit do termínu).

## Prezentácia a obhajoba

Demo funkčnej aplikácie (emulátor alebo zariadenie), **5 minút**, a rozhovor nad kódom. Pripravte sa na tri veci:

1. **ukážku riešenia** - prejdite hlavné obrazovky a ukážte, že aplikácia funguje,
2. **prehľad kódu** - z akých častí sa skladá, kde je ktorá vrstva, prečo je to tak rozdelené,
3. **zhodnotenie práce s LLM nástrojmi** - čo fungovalo, čo nie, čo ste museli opraviť sami.

Riešenie musíte vedieť **vysvetliť**, aj časti vytvorené pomocou LLM.

## Hodnotenie (40 %)

Hodnotia sa nasledujúce aspekty riešenia:

- funkčnosť a rozsah - spĺňa minimálne požiadavky, funguje, nepadá,
- mobilný aspekt - funkcie zariadenia, oprávnenia,
- dáta a backend - uloženie dát; pri backende aj autentifikácia a pravidlá prístupu,
- UI podľa návrhu a použiteľnosť,
- kvalita kódu a architektúra - vrstvy (UI / dáta / API), čitateľnosť,
- testy a CI - automatizované testy, ideálne spúšťané pri každom `git push`,
- dokumentácia vrátane použitia LLM a histórie promptov,
- priebeh - kontrolné body, commity počas semestra,
- prezentácia a obhajoba.

### Čo musí byť vidieť v repozitári

**Funkčnosť a rozsah** - aspoň 5 obrazoviek s navigáciou (bez backendu viac, pozri minimálne požiadavky);
aplikácia sa spustí podľa `code/app/LAUNCH.md` po čerstvom naklonovaní; bežné použitie nespadne; obrazovky,
ktoré načítavajú dáta, majú stav načítania, chyby a prázdneho zoznamu. Aplikácia, ktorú sa nepodarí spustiť
podľa priloženého návodu, sa hodnotí ako nefunkčná.

**Mobilný aspekt** - funkcie zariadenia skutočne použité v riešení (nie iba pridaný balíček); ošetrené
oprávnenia vrátane prípadu, keď ich používateľ odmietne. Pri projekte bez backendu má táto časť väčšiu váhu.

**Dáta a backend** - dáta prežijú reštart aplikácie. Pri backende navyše prihlásenie používateľa a
**pravidlá prístupu v repozitári**, ktoré zodpovedajú tomu, čo aplikácia robí (napr. používateľ vidí len svoje
dáta). Chýbajúce pravidlá v repozitári znamenajú stratu bodov za túto časť, aj keď aplikácia funguje.

**UI podľa návrhu** - obrazovky zodpovedajú návrhu z U2, odchýlky sú popísané v dokumentácii;
rozhranie sa dá ovládať bez vysvetľovania.

**Kvalita kódu a architektúra** - oddelené vrstvy (UI / dáta / API), nie všetko v jednom súbore;
konzistentné pomenovania; bez zakomentovaného mŕtveho kódu a bez prázdnych `catch` blokov, ktoré chybu zahodia.

**Testy a CI** - aspoň **3 automatizované testy**, ktoré niečo overujú (`expect`) a prechádzajú;
vygenerovaný `widget_test.dart`, ktorý zostal nezmenený a neprechádza, sa neráta.
Skúste aj **CI** (napr. GitHub Actions), ktorá pri každom `git push` spustí `flutter analyze` a testy.
Testy píšte priebežne, nie v posledný týždeň - zmyslom je zachytiť chybu skôr, ako ju zachytí hodnotiteľ.

**Dokumentácia** - všetky body zo zoznamu vyššie vrátane **vyplnenej tabuľky použitia LLM**
a **histórie promptov**.
