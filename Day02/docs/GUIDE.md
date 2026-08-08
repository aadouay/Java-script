# 🌿 JavaScript Mini-Course — Day02
## Guide Officiel du Projet

> 📖 **Resource Notion pour les concepts** : [JavaScript Mini-Course — Day02 Concepts](https://app.notion.com/p/JavaScript-mini-course-Day01-concepts-3b689112ac878013ba49fe52ac3b8e3c)  
> 📄 **Sujet PDF** : `docs/js02.pdf`

---

## 🎯 Objectif du Projet

L'objectif de **Day02** est d'apprendre la **manipulation des objets en JavaScript**.  
À travers 8 exercices (`ex00` à `ex07`), vous allez pratiquer :
- La création et l'accès aux objets (`dot notation` et `bracket notation`)
- L'inspection d'objets (`Object.keys()`, `Object.values()`, `Object.entries()`)
- La déstructuration d'objets
- La fusion d'objets avec le **spread operator** (`...`)
- La sérialisation / désérialisation avec **JSON** (`JSON.stringify()` et `JSON.parse()`)

---

## 📋 Règles Générales du Sujet (Style 42)

> ⚠️ **Attention** : Tout non-respect de ces règles peut invalider vos exercices lors de la correction.

1. **Aucun code en scope global** en dehors des définitions de fonctions.
2. **Un seul exercice par fichier**, exporté obligatoirement via `module.exports`.
3. **Appels directs de fonctions commentés** en fin de fichier (ex: `// ft_build_access("color", "black");`).
4. **Documentation JSDoc** requise sur chaque fonction.
5. **Indentation 2 espaces** et aucune fuite de variables globales.

---

## 📌 Aperçu des Exercices (ex00 à ex07)

| Exercice | Dossier | Fichier à rendre | Prototypes & Objectifs |
|---|---|---|---|
| **ex00** | `ex00/` | `ft_build_access.js` | `ft_build_access(key, value)` — Construire un objet, accéder via dot & bracket notation, ajouter une clé dynamique. |
| **ex01** | `ex01/` | `ft_list_keys.js` | `ft_list_keys(obj)` — Compter et lister les clés d'un objet avec `Object.keys()`. |
| **ex02** | `ex02/` | `ft_list_values.js` | `ft_list_values(obj)` — Lister les valeurs d'un objet avec `Object.values()`. |
| **ex03** | `ex03/` | `ft_entries_report.js` | `ft_entries_report(obj)` — Parcourir les entrées avec `Object.entries()` et une boucle `for...of`. |
| **ex04** | `ex04/` | `ft_destructure_me.js` | `ft_destructure_me(user)` — Déstructurer `name`, `age`, `city` en 1 ligne et afficher la phrase. |
| **ex05** | `ex05/` | `ft_merge_profiles.js` | `ft_merge_profiles(defaults, overrides)` — Fusionner 2 objets avec le spread operator (`...`). |
| **ex06** | `ex06/` | `ft_to_json.js` | `ft_to_json(obj)` — Convertir un objet en JSON string (`JSON.stringify`) et afficher son type. |
| **ex07** | `ex07/` | `ft_from_json.js` | `ft_from_json(jsonString)` — Parser du JSON (`JSON.parse`), afficher son type et une propriété. |

---

## 🧪 Moulinette d'Évaluation Automatique

Une moulinette automatique style **42 Paris** est fournie dans `srcs/tester/moulinette.sh`. Elle permet de tester instantanément vos fonctions et de valider votre code.

### ⚙️ Comment lancer la Moulinette ?

1. Rendez-vous dans le dossier `srcs/tester` :
   ```bash
   cd Day02/srcs/tester
   ```

2. Exécutez le script :
   ```bash
   # Pour tester TOUS les exercices (ex00 à ex07)
   ./moulinette.sh

   # Pour tester un exercice spécifique (ex: ex00)
   ./moulinette.sh 0
   ./moulinette.sh 5
   ```

### 📊 Comprendre les Résultats

- **`✓ PASS`** : Votre code produit la sortie exacte attendue.
- **`✗ FAIL`** : La sortie ne correspond pas (la moulinette affiche la différence entre *Attendu* et *Reçu*).
- **`⚠ SKIP`** : Le fichier de l'exercice n'est pas encore créé dans `srcs/exercises/exXX/`.

---

## 💡 Astuce de Validation

Avant d'exécuter la moulinette, vous pouvez effectuer un test rapide en ligne de commande Node.js :
```bash
node -e "const f = require('../exercises/ex00/ft_build_access.js'); f.ft_build_access('color', 'black');"
```
