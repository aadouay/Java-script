# 🌱 Day00 — Growing Code : JavaScript Fundamentals

> **Sujet** : Découvrir les bases de JavaScript à travers des données de jardins communautaires.
>
> **Concepts** : expressions, variables, fonctions, flux de contrôle, types primitifs.

---

## 📚 Cours Notion

Pour comprendre cette partie en profondeur, check ce lien :

🔗 [JavaScript Course — Notion](https://app.notion.com/p/JavaScript-mini-course-Day00-concepts-Growing-Code-38a89112ac8780ca9f0fe96a3ca7494d?source=copy_link)

---

## 📋 Termes Clés à Maîtriser

| Terme | Définition |
|-------|------------|
| **Variable** (`let`, `const`) | Un conteneur pour stocker une valeur. `let` est réassignable, `const` ne l'est pas. |
| **Types Primitifs** | `Number`, `String`, `Boolean`, `Undefined`, `Null`, `Symbol`, `BigInt` — les données les plus simples, immuables. |
| **Typage Dynamique** | En JS, le type est attaché à la **valeur**, pas à la variable. Une variable peut changer de type. |
| **Fonction** | Un bloc de code réutilisable : `function maFonction() { ... }` |
| **`console.log()`** | Affiche du texte dans le terminal (stdout). |
| **`module.exports`** | Permet d'exporter une fonction pour qu'elle soit importable par un autre fichier (CommonJS). |
| **Scope (Portée)** | Une variable `let`/`const` dans un bloc `{}` n'est visible que dans ce bloc. |
| **`parseInt()`** | Convertit une string en nombre entier : `parseInt("42")` → `42`. |
| **`readline-sync`** | Module npm pour lire l'input utilisateur de manière synchrone. |
| **JSDoc** | Commentaires structurés pour documenter les types : `@param {string} name`. |
| **Itératif vs Récursif** | Itératif = boucle `for`/`while`. Récursif = une fonction qui s'appelle elle-même. |

---

## 📝 Exercices du Day00

| # | Exercice | Fichier | Dossier | Concepts |
|---|----------|---------|---------|----------|
| 0 | Hello Garden | `ft_hello_garden.js` | `ex0/` | `console.log()`, fonctions, exports |
| 1 | Garden Name | `ft_garden_name.js` | `ex1/` | `readline-sync`, input/output |
| 2 | Garden Plot Area | `ft_plot_area.js` | `ex2/` | `parseInt()`, calcul, variables |
| 3 | Harvest Total | `ft_harvest_total.js` | `ex3/` | Additionner des inputs, total |
| 4 | Plant Age Check | `ft_plant_age.js` | `ex4/` | Conditions `if/else`, comparaison |
| 5 | Water Reminder | `ft_water_reminder.js` | `ex5/` | Conditions, logique |
| 6 | Count to Harvest | `ft_count_harvest_iterative.js` + `ft_count_harvest_recursive.js` | `ex6/` | Boucles, récursion |
| 7 | Seed Inventory | `ft_seed_inventory.js` | `ex7/` | JSDoc, `switch/if`, paramètres |

---

## ⚙️ Règles Générales

- Écrire **uniquement des fonctions** (pas de programme principal).
- **Ne pas appeler** la fonction dans le fichier.
- Exporter avec : `module.exports = { ft_ma_fonction };`
- Noms de fonctions **exactement** comme demandé.
- Indentation : **2 espaces**.
- Node.js **v18+**.

---

## 🧪 Tester avec la Moulinette Pro

```bash
# Compiler
g++ -std=c++17 -o tester_pro tester_pro.cpp

# Lancer un test
./tester_pro ex0/ft_hello_garden.js ex0_test.js "ft_hello_garden()" "Hello , Garden Community !"
```

La moulinette vérifie :
- ✅ Existence du fichier
- ✅ `module.exports` bien présent
- ✅ Sortie correcte (stdout)
- 💥 Crash / Segfault
- ⏱️ Timeout (boucle infinie)
- ⚠️ Erreurs stderr
