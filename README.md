# 🗺️ JavaScript — Roadmap Complète

> **Projet** : Moulinette JS — Un tester automatique pour valider les exercices JavaScript.
>
> Chaque Day couvre un thème fondamental de JavaScript, avec des exercices pratiques et un tester (moulinette) pour valider automatiquement les résultats.

---

## 🔧 La Moulinette (Tester)

### Architecture

```
JavaScript/
├── Day00/
│   ├── README.md                         ← README du Day
│   ├── docs/
│   │   ├── Guide.md                      ← Guide + termes clés
│   │   ├── cours-js-day00-concepts.md    ← Cours complet
│   │   └── js00.pdf                      ← Sujet officiel (PDF)
│   └── srcs/
│       ├── exercises/
│       │   ├── ex00/                     ← Exercices de l'étudiant
│       │   ├── ex01/
│       │   │   └── ft_hello_garden.js
│       │   ├── ex02/ ... ex07/
│       ├── tester/
│       │   ├── tester_pro.cpp            ← Moulinette PRO
│       │   └── moulinette_v.01           ← Binaire compilé
│       └── results/                      ← Résultats des tests
├── Day01/ ... Day09/                     ← (à venir, même structure)
└── README.md                             ← ← Tu es ici
```

### Fonctionnalités du Tester Pro

| Fonctionnalité | Description |
|----------------|-------------|
| 📁 Existence du fichier | Vérifie que le `.js` de l'étudiant existe |
| 📦 `module.exports` | Vérifie que la fonction est bien exportée |
| 📝 Sortie stdout | Compare la sortie avec l'output attendu |
| 💥 Crash / Segfault | Détecte les signaux (SIGSEGV, SIGABRT) |
| ⏱️ Timeout (5s) | Tue le processus si boucle infinie |
| ⚠️ Stderr | Capture les erreurs de syntaxe et exceptions |
| 🔢 Exit code | Vérifie un exit propre (code 0) |

### Usage

```bash
g++ -std=c++17 -o tester_pro tester_pro.cpp
./tester_pro <ex_file> <wrapper> <function_call> <expected_output>
```

---

## 📅 Planning des Days

### ✅ Day00 — Growing Code : JavaScript Fundamentals
> **Status** : `EN COURS`
>
> **Thème** : Syntaxe de base, variables, fonctions, flux de contrôle.

| # | Exercice | Concept Principal |
|---|----------|-------------------|
| 0 | Hello Garden | `console.log()`, fonctions, exports |
| 1 | Garden Name | `readline-sync`, input utilisateur |
| 2 | Garden Plot Area | `parseInt()`, calcul arithmétique |
| 3 | Harvest Total | Additionner des inputs, accumuler |
| 4 | Plant Age Check | Conditions `if/else` |
| 5 | Water Reminder | Logique conditionnelle |
| 6 | Count to Harvest | Boucles (itératif) + récursion |
| 7 | Seed Inventory | JSDoc, annotations de type, `switch` |

**Termes clés** : Variable, Type Primitif, Typage Dynamique, Scope, `module.exports`

📚 [Cours Notion Day00](https://app.notion.com/p/java-script-course-38a89112ac8780ca9f0fe96a3ca7494d?source=copy_link)

---

### 🔜 Day01 — Strings & Arrays
> **Status** : `À VENIR`
>
> **Thème** : Manipulation de chaînes de caractères et tableaux.

**Concepts attendus** :
- Méthodes de String : `.slice()`, `.split()`, `.replace()`, `.includes()`
- Template literals : `` `Hello ${name}` ``
- Arrays : `.push()`, `.pop()`, `.shift()`, `.unshift()`
- Parcourir un tableau : `for`, `for...of`
- `.length`, indexation `[]`

---

### 🔜 Day02 — Objects & Data Structures
> **Status** : `À VENIR`
>
> **Thème** : Objets, clé-valeur, structures de données.

**Concepts attendus** :
- Objets littéraux : `{ key: value }`
- Accès : dot notation vs bracket notation
- `Object.keys()`, `Object.values()`, `Object.entries()`
- Déstructuration : `const { name, age } = obj;`
- Spread operator : `{ ...obj }`
- JSON : `JSON.parse()`, `JSON.stringify()`

---

### 🔜 Day03 — Higher-Order Functions
> **Status** : `À VENIR`
>
> **Thème** : Fonctions comme valeurs, callbacks, fonctions d'ordre supérieur.

**Concepts attendus** :
- Fonctions anonymes et arrow functions : `() => {}`
- Callbacks
- `.map()`, `.filter()`, `.reduce()`
- `.forEach()`, `.find()`, `.some()`, `.every()`
- Closures (fermetures)

---

### 🔜 Day04 — Error Handling & Debugging
> **Status** : `À VENIR`
>
> **Thème** : Gestion des erreurs, exceptions, debugging.

**Concepts attendus** :
- `try / catch / finally`
- `throw new Error()`
- Types d'erreurs : `TypeError`, `ReferenceError`, `SyntaxError`
- Debugging avec `console.log()`, `console.error()`, `console.table()`
- Assertions basiques

---

### 🔜 Day05 — Asynchronous JavaScript
> **Status** : `À VENIR`
>
> **Thème** : Programmation asynchrone, Promises, async/await.

**Concepts attendus** :
- Event Loop (boucle d'événements)
- Callbacks asynchrones
- `setTimeout()`, `setInterval()`
- Promises : `new Promise()`, `.then()`, `.catch()`
- `async / await`
- `Promise.all()`, `Promise.race()`

---

### 🔜 Day06 — Classes & OOP
> **Status** : `À VENIR`
>
> **Thème** : Programmation orientée objet en JavaScript.

**Concepts attendus** :
- Classes ES6 : `class`, `constructor`
- Méthodes et propriétés
- Héritage : `extends`, `super`
- Getters / Setters
- `static` methods
- Encapsulation : champs privés `#`

---

### 🔜 Day07 — Modules & Project Structure
> **Status** : `À VENIR`
>
> **Thème** : Organisation du code, modules ES, npm.

**Concepts attendus** :
- CommonJS : `require()` / `module.exports`
- ES Modules : `import` / `export`
- `package.json`, npm init
- Dépendances : `npm install`
- Scripts npm : `npm run`
- Organisation d'un projet multi-fichiers

---

### 🔜 Day08 — DOM & Browser APIs
> **Status** : `À VENIR`
>
> **Thème** : Manipulation du DOM, événements, APIs navigateur.

**Concepts attendus** :
- `document.querySelector()`, `getElementById()`
- Créer / modifier / supprimer des éléments
- Événements : `addEventListener()`
- Event delegation, bubbling, capturing
- `fetch()` API
- `localStorage`, `sessionStorage`

---

### 🔜 Day09 — Final Project
> **Status** : `À VENIR`
>
> **Thème** : Projet final intégrant tous les concepts.

**Concepts attendus** :
- Application complète combinant tous les Days
- Architecture propre et modulaire
- Gestion d'erreurs robuste
- Tests et validation
- Documentation (JSDoc, README)

---

## 📊 Progression Globale

```
Day00  [██░░░░░░░░]  20%  ← EN COURS
Day01  [░░░░░░░░░░]   0%  ← À VENIR
Day02  [░░░░░░░░░░]   0%
Day03  [░░░░░░░░░░]   0%
Day04  [░░░░░░░░░░]   0%
Day05  [░░░░░░░░░░]   0%
Day06  [░░░░░░░░░░]   0%
Day07  [░░░░░░░░░░]   0%
Day08  [░░░░░░░░░░]   0%
Day09  [░░░░░░░░░░]   0%
────────────────────────
Total  [█░░░░░░░░░]   2%
```

---

## 🔮 Évolution de la Moulinette

| Version | Description | Status |
|---------|-------------|--------|
| v0.1 | Tester basique — compare stdout uniquement | ✅ Fait |
| v1.0 | **Tester Pro** — crash, timeout, stderr, exports | ✅ Fait |
| v1.1 | Support `readline-sync` (input simulé) | 🔜 À faire |
| v2.0 | Config YAML — définir les tests dans un fichier | 🔜 À faire |
| v3.0 | Multi-test — lancer tous les exos d'un Day d'un coup | 🔜 À faire |

---

> 💡 **Note** : Les Day01 à Day09 seront ajoutés prochainement. Cette roadmap sera mise à jour au fur et à mesure de l'avancement.
