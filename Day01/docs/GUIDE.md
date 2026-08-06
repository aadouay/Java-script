# 🌿 JavaScript Mini-Course — Day01
## Guide Complet du Projet

> 📖 **Concepts officiels** : [JavaScript mini-course — Day01](https://app.notion.com/p/JavaScript-mini-course-Day01-concepts-3b489112ac878019b837f2cdd322fa71)

---

## 🎯 Objectif du Projet

Day01 introduit les **méthodes de manipulation de chaînes et de tableaux** en JavaScript.
L'objectif est d'apprendre à transformer, filtrer et réduire des données à l'aide des méthodes fonctionnelles natives de JavaScript.

À la fin de ce projet tu seras capable de :
- Manipuler les **tableaux** avec `map`, `filter`, `reduce`, `forEach`
- Manipuler les **chaînes** avec `split`, `slice`, `join`, `includes`, `indexOf`
- Comprendre la différence entre **méthodes mutables et immutables**
- Écrire des fonctions **pures** et **fonctionnelles**
- Exporter correctement des fonctions avec `module.exports`

---

## 📚 Concepts Clés à Maîtriser

### 1️⃣ `slice` vs `split`

| Méthode | Type  | Description |
|---------|-------|-------------|
| `slice(start, end)` | Tableau / Chaîne | Extrait une portion **sans modifier** l'original |
| `split(separator)` | Chaîne → Tableau | Découpe une chaîne en tableau selon un séparateur |

```javascript
// slice sur une chaîne
"Hello World".slice(0, 5)        // → "Hello"
"Hello World".slice(-5)          // → "World"

// split sur une chaîne
"a,b,c".split(",")               // → ["a", "b", "c"]
"Hello".split("")                // → ["H", "e", "l", "l", "o"]

// slice sur un tableau
[1, 2, 3, 4].slice(1, 3)         // → [2, 3]
```

---

### 2️⃣ `map` — Transformer un tableau

Applique une fonction à chaque élément et retourne un **nouveau tableau**.

```javascript
const numbers = [1, 2, 3];
const doubled = numbers.map(n => n * 2);   // → [2, 4, 6]

const names = ["alice", "bob"];
const upper = names.map(n => n.toUpperCase()); // → ["ALICE", "BOB"]
```

---

### 3️⃣ `filter` — Filtrer un tableau

Retourne un **nouveau tableau** contenant seulement les éléments qui passent le test.

```javascript
const numbers = [1, 2, 3, 4, 5, 6];
const evens = numbers.filter(n => n % 2 === 0);  // → [2, 4, 6]
const odds  = numbers.filter(n => n % 2 !== 0);  // → [1, 3, 5]
```

---

### 4️⃣ `reduce` — Accumuler en une seule valeur

Réduit un tableau à **une seule valeur** (somme, produit, objet...).

```javascript
const numbers = [1, 2, 3, 4];
const sum = numbers.reduce((acc, n) => acc + n, 0);   // → 10
const product = numbers.reduce((acc, n) => acc * n, 1); // → 24
```

---

### 5️⃣ `forEach` — Itérer sans retour

Exécute une fonction pour chaque élément, **sans retourner** de tableau.

```javascript
const fruits = ["apple", "banana", "cherry"];
fruits.forEach((fruit, index) => {
    console.log(`${index}: ${fruit}`);
});
// 0: apple
// 1: banana
// 2: cherry
```

---

### 6️⃣ Autres méthodes utiles

```javascript
// join — Tableau → Chaîne
["a", "b", "c"].join("-")        // → "a-b-c"
["a", "b", "c"].join("")         // → "abc"

// includes — Vérifier la présence
["a", "b", "c"].includes("b")    // → true
"Hello World".includes("World")  // → true

// indexOf — Trouver la position
["a", "b", "c"].indexOf("b")     // → 1
[1, 2, 3].indexOf(99)            // → -1

// find / findIndex
[1, 2, 3, 4].find(n => n > 2)          // → 3
[1, 2, 3, 4].findIndex(n => n > 2)     // → 2

// flat / flatMap
[[1, 2], [3, 4]].flat()          // → [1, 2, 3, 4]
```

---

## 📁 Structure du Projet

```
Day01/
├── docs/
│   └── GUIDE.md          ← Ce fichier
├── srcs/
│   ├── exercises/
│   │   ├── ex00/         ← ft_slice_split.js
│   │   ├── ex01/         ← (à compléter)
│   │   ├── ex02/         ← (à compléter)
│   │   └── ...
│   └── tester/
│       ├── tester_pro.cpp
│       ├── tester_pro     (compilé automatiquement)
│       └── moulinette.sh
└── README.md
```

---

## 📋 Règles du Sujet (identiques à Day00)

> ⚠️ **Ces règles sont obligatoires pour passer la Moulinette de 42 !**

1. **Écrire UNIQUEMENT des fonctions** — Pas de code en dehors des fonctions
2. **Ne pas appeler la fonction dans le fichier** — Toujours commenter l'appel direct
3. **Exporter avec `module.exports`** :
   ```javascript
   module.exports = { ft_ma_fonction };
   ```
4. **Nommer les fichiers exactement** comme demandé (ex: `ft_slice_split.js`)

### ✅ Structure correcte

```javascript
// ft_slice_split.js

/**
 * @param {string} str - La chaîne à découper
 * @param {number} start - Index de début
 * @param {number} end - Index de fin
 * @returns {string}
 */
const ft_slice_split = (str, start, end) => {
    // Ta logique ici
};

// ft_slice_split("Hello", 0, 3); // Ne pas décommenter !

module.exports = { ft_slice_split };
```

---

## 🚀 Utiliser la Moulinette Day01

La moulinette est un **testeur automatique style 42 Paris** qui vérifie ton code.

### Installation (première fois)

```bash
cd Day01/srcs/tester
g++ -std=c++17 -o tester_pro tester_pro.cpp
```

### Lancer tous les tests

```bash
cd Day01/srcs/tester
./moulinette.sh
```

### Tester un seul exercice

```bash
./moulinette.sh 0    # Tester seulement ex00
./moulinette.sh 2    # Tester seulement ex02
./moulinette.sh 5    # Tester seulement ex05
```

### Lire les résultats

```
╔════════════════════════════════════════════╗
║  Exercise 0 : Slice & Split
╚════════════════════════════════════════════╝
  ─── Test 1 ───
  ✓ PASS — Test 1
  ─── Test 2 ───
  ✗ FAIL — Test 2
             Attendu : "Hello"
             Reçu    : "hello"
```

| Symbole | Signification |
|---------|---------------|
| ✓ PASS | Test réussi |
| ✗ FAIL | Test échoué — voir l'attendu vs reçu |
| ⚠ SKIP | Fichier introuvable — crée le fichier ! |

### Résumé final

```
  ║  ex00: ✓ PASS (3/3)
  ║  ex01: ✗ FAIL (1/3)
  ║  ex02: ⚠ SKIP
```

---

## 💡 Conseils

1. **Vérifie le nom du fichier** : `ft_slice_split.js` ≠ `FtSliceSplit.js`
2. **Teste d'abord manuellement** :
   ```bash
   node -e "const f = require('./ft_slice_split.js'); console.log(f.ft_slice_split('Hello', 0, 3));"
   ```
3. **Lit attentivement le diff** : la moulinette affiche exactement ce qu'elle attendait vs ce qu'elle a reçu
4. **Respecte la casse et les espaces** dans les chaînes de sortie
5. **Lis le PDF** `js01.pdf` dans le dossier `docs/` pour les instructions exactes de chaque exercice

---

## 📖 Ressources Supplémentaires

- 📘 [Concepts Day01 (Notion)](https://app.notion.com/p/JavaScript-mini-course-Day01-concepts-3b489112ac878019b837f2cdd322fa71)
- 📄 [MDN — Array methods](https://developer.mozilla.org/fr/docs/Web/JavaScript/Reference/Global_Objects/Array)
- 📄 [MDN — String methods](https://developer.mozilla.org/fr/docs/Web/JavaScript/Reference/Global_Objects/String)
- 📄 [MDN — map()](https://developer.mozilla.org/fr/docs/Web/JavaScript/Reference/Global_Objects/Array/map)
- 📄 [MDN — filter()](https://developer.mozilla.org/fr/docs/Web/JavaScript/Reference/Global_Objects/Array/filter)
- 📄 [MDN — reduce()](https://developer.mozilla.org/fr/docs/Web/JavaScript/Reference/Global_Objects/Array/Reduce)
