# Mini-cours JavaScript — Concepts du Day00 (Growing Code)

Tous les concepts nécessaires pour réussir le projet, expliqués avec des exemples sur le thème d'une **boulangerie** (pour ne pas te donner la solution du jardin). À toi de transposer chaque concept à ton propre sujet.

---

## 1. Les fonctions

### 1.1 C'est quoi une fonction ?

Un bloc de code réutilisable, qu'on définit une fois et qu'on exécute (appelle) autant de fois qu'on veut. Elle peut recevoir des **paramètres** (entrées) et produire une **sortie**.

```javascript
function direBonjour(nom) {
  console.log(`Bonjour ${nom} !`);
}

// La fonction ne fait rien tant qu'on ne l'appelle pas :
direBonjour;        // ne fait rien, juste une référence

// Pour l'exécuter :
direBonjour("Karim"); // "Bonjour Karim !"
direBonjour("Sara");  // "Bonjour Sara !"
```

Une fonction, c'est comme une machine : tu la construis une fois (la définition), tu l'actives autant de fois que nécessaire (l'appel), avec des ingrédients différents à chaque fois (les paramètres).

### 1.2 Les différentes façons d'écrire une fonction

**a) Déclaration de fonction (function declaration)** — celle demandée dans ton projet :
```javascript
function direBonjour(nom) {
  console.log(`Bonjour ${nom}`);
}
```

**b) Expression de fonction :**
```javascript
const direBonjour = function (nom) {
  console.log(`Bonjour ${nom}`);
};
```

**c) Arrow function (fonction fléchée) :**
```javascript
const direBonjour = (nom) => {
  console.log(`Bonjour ${nom}`);
};
```

> **Pour ce projet** : utilise toujours la déclaration classique `function ft_nom() {}`, car le sujet impose des noms de fonctions précis avec `module.exports`.

### 1.3 `console.log` vs `return` — la différence à ne jamais confondre

```javascript
function additionner(a, b) {
  console.log(a + b); // affiche à l'écran, mais ne renvoie rien au code
}

function additionnerV2(a, b) {
  return a + b; // renvoie la valeur, utilisable ailleurs dans le code
}

const resultat1 = additionner(2, 3);   // affiche "5" dans le terminal
console.log(resultat1);                 // undefined ! (pas de return)

const resultat2 = additionnerV2(2, 3); // n'affiche rien
console.log(resultat2);                 // 5
```

- `console.log()` → affiche quelque chose pour que **toi** tu voies (sortie visuelle)
- `return` → renvoie une valeur pour que **le reste du code** puisse l'utiliser

> Dans ce projet, les fonctions demandées **affichent directement** avec `console.log`. C'est pour ça que le sujet précise `@returns {void}` dans l'exercice 7 : la fonction ne renvoie rien, elle se contente d'afficher.

---

## 2. `console` : un objet, pas une fonction isolée

`console` est un **objet global** fourni par Node.js, qui contient plusieurs **méthodes** (= fonctions qui appartiennent à un objet) :

```javascript
console.log("Bonjour");    // message normal
console.error("Erreur !"); // message d'erreur (souvent en rouge)
console.warn("Attention"); // avertissement (souvent en jaune)
```

Simplifié, `console` ressemble à ceci :
```javascript
const console = {
  log: function (message) { /* affiche le message */ },
  error: function (message) { /* affiche en rouge */ },
  warn: function (message) { /* affiche en jaune */ }
};
```

Même logique que n'importe quel objet à toi :
```javascript
const boulangerie = {
  vendre: function (article) {
    console.log(`Vente de ${article}`);
  }
};

boulangerie.vendre("pain"); // "Vente de pain"
```

`boulangerie.vendre(...)` fonctionne exactement comme `console.log(...)` : un objet, un point, une méthode, des parenthèses avec des arguments.

---

## 3. `module.exports` : rendre une fonction utilisable ailleurs

En Node.js, chaque fichier est un **module** isolé. Pour qu'une fonction écrite dans un fichier soit utilisable depuis un autre fichier (comme le testeur automatique du projet), il faut l'exporter :

```javascript
// fichier: ft_saluer.js
function ft_saluer() {
  console.log('Bonjour, boulangerie !');
}

module.exports = ft_saluer;
```

Un autre fichier peut alors faire :
```javascript
// fichier: test.js
const ft_saluer = require('./ft_saluer.js');
ft_saluer(); // "Bonjour, boulangerie !"
```

> **Règle du sujet** : chaque fichier ne doit contenir QUE la fonction demandée + son export. Pas d'appel de la fonction dans le même fichier.

---

## 4. Lire une entrée utilisateur avec `readline-sync`

Par défaut, Node.js lit les entrées de façon **asynchrone** (compliqué à gérer). Le package `readline-sync` permet de le faire en **synchrone** (simple : une ligne à la fois, le code attend la réponse).

Installation :
```bash
npm install readline-sync
```

Utilisation :
```javascript
const readlineSync = require('readline-sync');

function ft_demander_prenom() {
  const prenom = readlineSync.question('Entrez votre prénom : ');
  console.log(`Bonjour, ${prenom} !`);
}

module.exports = ft_demander_prenom;
```

`readlineSync` est lui aussi un **objet**, avec une méthode `.question()` qui :
1. Affiche le texte passé en argument
2. **Attend** que l'utilisateur tape une réponse et appuie sur Entrée
3. Retourne ce que l'utilisateur a tapé — **toujours sous forme de string**, même si c'est un chiffre !

---

## 5. `parseInt()` : convertir une string en nombre

Piège classique : `readlineSync.question()` retourne toujours du texte, même si l'utilisateur tape "5".

```javascript
const readlineSync = require('readline-sync');

const texteEntree = readlineSync.question('Entrez un nombre : ');
console.log(typeof texteEntree); // "string", même si l'utilisateur a tapé 5

const nombre = parseInt(texteEntree);
console.log(typeof nombre); // "number"
```

Pourquoi c'est important :
```javascript
const a = "5";
const b = "3";

console.log(a + b);                       // "53"  (concaténation de strings !)
console.log(parseInt(a) + parseInt(b));   // 8     (addition de nombres)
```

Sans `parseInt`, additionner deux réponses utilisateur va **coller les textes** au lieu de faire un calcul.

---

## 6. Les types de données utilisés dans ce projet

| Type | Exemple | `typeof` |
|---|---|---|
| `string` | `"pain"` | `"string"` |
| `number` | `42`, `3.14` | `"number"` |
| `boolean` | `true`, `false` | `"boolean"` |
| `undefined` | variable déclarée sans valeur | `"undefined"` |

```javascript
const article = "baguette"; // string
const prix = 2.5;            // number
const enStock = true;        // boolean

console.log(typeof article); // "string"
console.log(typeof prix);    // "number"
console.log(typeof enStock); // "boolean"
```

---

## 7. Les conditions (`if` / `else`)

```javascript
function ft_verifier_stock(quantite) {
  if (quantite > 10) {
    console.log('Stock suffisant');
  } else {
    console.log('Stock faible');
  }
}
```

**`if` / `else if` / `else` :**
```javascript
function ft_categorie_temps(jours) {
  if (jours > 2) {
    console.log('Trop de temps a passé');
  } else if (jours === 2) {
    console.log('Exactement 2 jours');
  } else {
    console.log('Récent');
  }
}
```

**Les opérateurs de comparaison :**
```javascript
5 > 3    // true  → supérieur à
5 < 3    // false → inférieur à
5 >= 5   // true  → supérieur ou égal
5 <= 3   // false → inférieur ou égal
5 === 5  // true  → égal (valeur ET type) — à utiliser TOUJOURS
5 !== 3  // true  → différent
```

> Utilise toujours `===` et `!==` (jamais `==`/`!=`), car `==` fait des conversions de type automatiques qui peuvent créer des bugs surprenants (ex: `"5" == 5` donne `true`).

---

## 8. Les boucles (itératif)

**Boucle `for`** — idéale quand tu connais le nombre de répétitions :
```javascript
function ft_compter_jusqua(n) {
  for (let i = 1; i <= n; i++) {
    console.log(`Étape ${i}`);
  }
}
```

Décomposition des 3 parties du `for` :
- `let i = 1` → point de départ (exécuté une seule fois)
- `i <= n` → condition vérifiée à chaque tour ; tant que c'est `true`, la boucle continue
- `i++` → exécuté après chaque tour (équivaut à `i = i + 1`)

**Boucle `while`** — alternative, utile quand la condition d'arrêt n'est pas un simple compteur :
```javascript
function ft_compter_while(n) {
  let i = 1;
  while (i <= n) {
    console.log(`Étape ${i}`);
    i++;
  }
}
```

---

## 9. La récursivité

Une fonction récursive **s'appelle elle-même**. Elle a toujours besoin de deux éléments :

1. **Un cas de base** : condition d'arrêt, sinon la fonction s'appelle à l'infini (→ crash)
2. **Un appel récursif** qui se rapproche à chaque fois du cas de base

```javascript
function ft_compte_a_rebours(n) {
  if (n <= 0) {                  // cas de base : on arrête ici
    console.log('Fini !');
    return;
  }
  console.log(n);
  ft_compte_a_rebours(n - 1);    // appel récursif, se rapproche de 0
}
```

Trace d'exécution pour `ft_compte_a_rebours(3)` :
```
ft_compte_a_rebours(3) → affiche 3 → appelle ft_compte_a_rebours(2)
ft_compte_a_rebours(2) → affiche 2 → appelle ft_compte_a_rebours(1)
ft_compte_a_rebours(1) → affiche 1 → appelle ft_compte_a_rebours(0)
ft_compte_a_rebours(0) → n <= 0 → affiche "Fini !" → s'arrête
```

**Différence avec l'itératif** : au lieu d'une boucle `for`/`while` qui tourne dans la même fonction, ici la fonction se relance elle-même jusqu'à atteindre la condition d'arrêt.

---

## 10. JSDoc : annoter les types

JavaScript n'a pas de typage strict comme Java (une variable peut changer de type). JSDoc est une convention de **commentaire** qui documente les types attendus, pour que ce soit plus clair pour qui lit le code :

```javascript
/**
 * @param {string} nom
 * @param {number} age
 * @returns {void}
 */
function ft_presenter(nom, age) {
  console.log(`${nom} a ${age} ans`);
}
```

- `@param {type} nomDuParametre` → décrit chaque paramètre attendu
- `@returns {type}` → décrit ce que retourne la fonction
- `{void}` → signifie "ne retourne rien" (la fonction fait juste un `console.log`, pas de `return valeur`)

> C'est optionnel pour les exercices 0 à 6 du sujet, mais **obligatoire** pour l'exercice 7.

---

## 11. Comparer des strings (utile pour un `if` sur du texte)

```javascript
function ft_verifier_unite(unite) {
  if (unite === 'kg') {
    console.log('Unité : kilogrammes');
  } else if (unite === 'litres') {
    console.log('Unité : litres');
  } else {
    console.log('Unité inconnue');
  }
}
```

`===` sur des strings compare le contenu **exact**, y compris la casse : `"KG" !== "kg"`.

---

## 12. Objet vs Fonction vs Méthode (résumé visuel)

```javascript
// FONCTION simple (autonome)
function saluer() {
  console.log("Salut");
}

// OBJET (collection de données ET/OU fonctions)
const personne = {
  nom: "Yassine",       // propriété (donnée)
  age: 25,               // propriété (donnée)
  saluer: function () {  // méthode (fonction À L'INTÉRIEUR d'un objet)
    console.log("Salut, moi c'est " + this.nom);
  }
};

saluer();           // appel d'une fonction normale
personne.saluer();   // appel d'une MÉTHODE (fonction attachée à un objet)
```

- **Fonction** = bloc de code autonome, appelé directement par son nom
- **Objet** = collection de clé/valeur, peut contenir des données ET des fonctions
- **Méthode** = le nom qu'on donne à une fonction quand elle vit **à l'intérieur** d'un objet

`console`, `readlineSync`, `Math`, `JSON` sont tous des objets natifs de JS regroupant des méthodes prêtes à l'emploi.

---

## 13. Règles de style attendues (ESLint)

```javascript
// ✅ Correct
function ft_exemple(param) {
  const valeur = param * 2;
  console.log(valeur);
}

module.exports = ft_exemple;
```

```javascript
// ❌ Incorrect : pas de const/let → fuite de variable globale
function ft_exemple(param) {
  valeur = param * 2; // erreur ESLint
  console.log(valeur);
}
```

Points de vigilance :
- Toujours déclarer avec `const` ou `let`, jamais de variable "nue" (sans mot-clé)
- Indentation de **2 espaces**, jamais de tabulation
- Un fichier = une seule fonction exportée, aucun code exécuté en dehors de la fonction (pas d'appel direct dans le fichier)

---

## 14. Tableau récapitulatif : concepts par exercice du sujet

| Exercice | Nouveaux concepts à mobiliser |
|---|---|
| Ex0 | `function`, `console.log`, `module.exports` |
| Ex1 | + `readlineSync.question` |
| Ex2 | + `parseInt`, opérateurs arithmétiques |
| Ex3 | + plusieurs inputs, addition cumulée |
| Ex4 | + `if` / `else`, opérateurs de comparaison |
| Ex5 | + `if` / `else` à 2 branches |
| Ex6 | + boucle `for`/`while` (itératif) ET récursivité |
| Ex7 | + JSDoc, comparaison de strings avec `===` |

---

## Prochaine étape

Essaie d'écrire `ft_hello_garden` (Exercice 0) par toi-même en appliquant les sections 1, 2 et 3 de ce cours.
