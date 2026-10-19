# U1 – Návrh vlastného projektu

**Typ projektu:** Mobilná aplikácia na správu nákupov a domácich zásob  
**Názov aplikácie:** Zatiaľ neurčený  
**Platforma:** Android (Flutter / Dart)

## Problém a cieľová skupina

Ľudia často strácajú prehľad o tom, čo potrebujú nakúpiť, aké potraviny už majú doma a kedy ich treba spotrebovať. Výsledkom môžu byť zbytočné nákupy a plytvanie potravinami. Cieľom projektu je vytvoriť jednoduchú mobilnú aplikáciu, ktorá spojí **nákupný zoznam s evidenciou domácich zásob** a pomôže používateľovi sledovať stav potravín. Aplikácia je určená najmä domácnostiam, ktoré chcú mať lepší prehľad o svojich nákupoch.

## Hlavné funkcionality

1. **Nákupný zoznam** – pridávanie, úprava, odškrtávanie a mazanie položiek. Zakúpenú potravinu bude možné presunúť priamo do domácich zásob.
2. **Správa domácich zásob** – evidencia potravín podľa kategórie, množstva v kusoch alebo baleniach a miesta uskladnenia (napr. chladnička, mraznička, špajza). Pri balených produktoch sa bude rozlišovať medzi otvorenými a neotvorenými baleniami; bez potreby sledovať presnú spotrebovanú gramáž.
3. **Sledovanie stavu potravín** – pri balených produktoch evidencia dátumu spotreby alebo minimálnej trvanlivosti a prípadne dátumu otvorenia. Pri ovocí, napríklad banánoch či avokáde, bude možné manuálne nastaviť stupeň zrelosti. Aplikácia zvýrazní potraviny, ktorým sa blíži koniec trvanlivosti alebo vyžadujú kontrolu.
4. **Upozornenia a pripomienky** – lokálne notifikácie o blížiacom sa dátume spotreby alebo o potrebe skontrolovať zrelosť. Po spotrebovaní bude možné potravinu jednoducho pridať späť na nákupný zoznam.

## Využitie mobilných technológií

Aplikácia bude využívať **lokálne notifikácie**, **offline režim** a lokálne úložisko telefónu. Ako voliteľné rozšírenie sa plánuje využitie **fotoaparátu** na odfotenie potraviny alebo rozpoznanie dátumu z obalu pomocou OCR; rozpoznaný dátum bude vždy možné manuálne opraviť.

## Architektúra a ukladanie dát

Aplikácia bude vytvorená vo **Flutteri (Dart)**. Používateľské údaje, nákupné zoznamy a domáce zásoby sa budú ukladať do **lokálnej databázy SQLite**. Predpripravený katalóg bežných potravín a ich základných vlastností bude súčasťou aplikácie (napr. vo formáte JSON). Základná verzia **nebude potrebovať serverový backend, cloud ani internetové pripojenie**. Na prácu s databázou a upozorneniami sa použijú Flutter balíky; OCR bude prípadným rozšírením podľa časových možností.
