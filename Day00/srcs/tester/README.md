# 🔧 Moulinette PRO v2.0 — Guide du Tester

> Tester automatique pour valider les exercices JavaScript du Day00.
>
> Inspiré de la moulinette de **42 Paris** 🏫

---

## 🚀 Quick Start

```bash
# 1. Se placer dans le dossier tester
cd Day00/srcs/tester/

# 2. Lancer la moulinette (teste TOUS les exercices)
./moulinette.sh

# 3. Ou tester un seul exercice
./moulinette.sh 1    # Seulement ex01
```

C'est tout ! La moulinette compile automatiquement le tester si nécessaire.

---

## 📂 Fichiers

| Fichier | Description |
|---------|-------------|
| `moulinette.sh` | 🌱 Script principal — lance tous les tests automatiquement |
| `tester_pro.cpp` | ⚙️ Moteur de test C++ (compile → `tester_pro`) |
| `tester_pro` | 🔧 Binaire compilé (généré automatiquement) |

---

## 🌱 Moulinette — Mode automatique

Lance **tous les exercices** avec plusieurs cas de test chacun :

```bash
./moulinette.sh
```

**Sortie exemple :**
```
  ╔══════════════════════════════════════════════════════╗
  ║         🌱 MOULINETTE DAY00 — Growing Code 🌱       ║
  ╚══════════════════════════════════════════════════════╝

╔════════════════════════════════════════════╗
║  Exercise 0 : Hello Garden
╚════════════════════════════════════════════╝
  ✓ PASS — Test basique

╔════════════════════════════════════════════╗
║  Exercise 1 : Garden Name
╚════════════════════════════════════════════╝
  ✓ PASS — Input: Community Garden
  ✓ PASS — Input: Roses
  ✓ PASS — Input: 42 Paris

  ╔══════════════════════════════════════════════════════╗
  ║              RÉSUMÉ GLOBAL — DAY00                   ║
  ╠══════════════════════════════════════════════════════╣
  ║  ex00: ✓ PASS (1/1)
  ║  ex01: ✓ PASS (3/3)
  ║  ex02: SKIP
  ║  ...
  ╠══════════════════════════════════════════════════════╣
  ║  ★  MOULINETTE : 100%  — TOUS LES TESTS PASSENT  ★  ║
  ╚══════════════════════════════════════════════════════╝
```

### Tester un seul exercice

```bash
./moulinette.sh 0    # ex00 — Hello Garden
./moulinette.sh 1    # ex01 — Garden Name
./moulinette.sh 2    # ex02 — Garden Plot Area
./moulinette.sh 3    # ex03 — Harvest Total
./moulinette.sh 4    # ex04 — Plant Age Check
./moulinette.sh 5    # ex05 — Water Reminder
./moulinette.sh 6    # ex06 — Count to Harvest
./moulinette.sh 7    # ex07 — Seed Inventory
```

### Statuts possibles

| Statut | Signification |
|--------|---------------|
| ✓ PASS | Le test est validé ✅ |
| ✗ FAIL | La sortie ne correspond pas à l'attendu ❌ |
| ⚠ SKIP | Le fichier de l'exercice n'existe pas encore ⏭️ |

---

## ⚙️ Tester PRO — Mode manuel

Pour tester un fichier spécifique manuellement, le binaire `tester_pro` supporte 3 modes :

### Mode 1 — Wrapper (avec `module.exports`)

Pour les exercices qui exportent une fonction (ex00, ex07) :

```bash
./tester_pro <fichier.js> <wrapper.js> <appel_fonction> <sortie_attendue>
```

**Exemple :**
```bash
./tester_pro ../exercises/ex00/ft_hello_garden.js wrap.js \
    "ft_hello_garden()" "Hello , Garden Community !"
```

**Tests effectués :**
1. ✅ Existence du fichier
2. ✅ Vérification de `module.exports`
3. ✅ Comparaison de la sortie stdout

---

### Mode 2 — Direct (exécution directe)

Pour les exercices sans `module.exports` :

```bash
./tester_pro --direct <fichier.js> <sortie_attendue>
```

---

### Mode 3 — Direct + Stdin (pour `readline-sync`)

Pour les exercices qui utilisent `readline-sync` (ex01 → ex06) :

```bash
./tester_pro --direct --stdin "<input>" <fichier.js> <sortie_attendue>
```

**Exemple :**
```bash
./tester_pro --direct --stdin "Roses" \
    ../exercises/ex01/ft_garden_name.js \
    "Enter garden name : Garden : Roses\nStatus : Growing well !"
```

> 💡 **Comment ça marche ?** Le tester crée un **faux module `readline-sync`**
> qui retourne les réponses pré-configurées au lieu de lire depuis le terminal.
> Ainsi, pas besoin de taper manuellement !

**Inputs multiples** — séparer par `\n` :
```bash
./tester_pro --direct --stdin "5\n3" \
    ../exercises/ex02/ft_plot_area.js \
    "Enter length : Enter width : Plot area : 15"
```

---

## 🛡️ Vérifications effectuées

| Test | Description |
|------|-------------|
| 📁 Existence du fichier | Vérifie que le `.js` existe |
| 📦 `module.exports` | Vérifie que la fonction est exportée (mode wrapper) |
| 📝 Sortie stdout | Compare la sortie avec l'output attendu |
| 💥 Crash / Segfault | Détecte les signaux (SIGSEGV, SIGABRT) |
| ⏱️ Timeout (5s) | Tue le processus si boucle infinie |
| ⚠️ Stderr | Capture les erreurs de syntaxe et exceptions |
| 🔢 Exit code | Vérifie un exit propre (code 0) |

---

## 🔨 Recompiler manuellement

Si besoin de recompiler le tester après modification :

```bash
g++ -std=c++17 -o tester_pro tester_pro.cpp
```

---

## 📋 Cas de test par exercice

| Ex | Fichier | Nb tests | Mode | Inputs testés |
|----|---------|----------|------|---------------|
| 00 | `ft_hello_garden.js` | 1 | wrapper | — |
| 01 | `ft_garden_name.js` | 3 | direct+stdin | `Community Garden`, `Roses`, `42 Paris` |
| 02 | `ft_plot_area.js` | 3 | direct+stdin | `5×3`, `10×10`, `1×1` |
| 03 | `ft_harvest_total.js` | 3 | direct+stdin | `5+8+3`, `10+20+30`, `0+0+0` |
| 04 | `ft_plant_age.js` | 4 | direct+stdin | `75`, `61`, `60`, `30` |
| 05 | `ft_water_reminder.js` | 4 | direct+stdin | `3`, `5`, `2`, `1` |
| 06 | `ft_count_harvest_*.js` | 4 | direct+stdin | iterative+recursive × `5`, `1` |
| 07 | `ft_seed_inventory.js` | 4 | wrapper | `packets`, `grams`, `area`, `unknown` |

---

> 🌱 **Astuce** : Lance `./moulinette.sh` après chaque exercice terminé pour vérifier que tout passe avant de push !
