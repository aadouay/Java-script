# 🌱 Day00 — Growing Code : JavaScript Fundamentals

> **Thème** : Syntaxe de base, variables, fonctions, flux de contrôle.

---

## 📂 Structure

```
Day00/
├── docs/
│   ├── Guide.md                         ← Guide + termes clés du Day
│   ├── cours-js-day00-concepts.md       ← Cours complet sur les concepts
│   └── js00.pdf                         ← Sujet officiel (PDF)
├── srcs/
│   ├── exercises/
│   │   ├── ex00/                        ← Hello Garden
│   │   ├── ex01/                        ← Garden Name
│   │   │   └── ft_hello_garden.js
│   │   ├── ex02/                        ← Garden Plot Area
│   │   ├── ex03/                        ← Harvest Total
│   │   ├── ex04/                        ← Plant Age Check
│   │   ├── ex05/                        ← Water Reminder
│   │   ├── ex06/                        ← Count to Harvest
│   │   └── ex07/                        ← Seed Inventory
│   ├── tester/
│   │   ├── tester_pro.cpp               ← Moulinette PRO (tester avancé)
│   │   └── moulinette_v.01              ← Binaire compilé (ancienne version)
│   └── results/                         ← Résultats des tests
└── README.md                            ← ← Tu es ici
```

---

## 🧪 Usage du Tester

```bash
# Compiler
cd srcs/tester/
g++ -std=c++17 -o tester_pro tester_pro.cpp

# Lancer un test
./tester_pro ../exercises/ex01/ft_hello_garden.js wrapper.js "ft_hello_garden()" "Hello , Garden Community !"
```

---

## 📋 Exercices

| # | Exercice | Fichier | Concepts |
|---|----------|---------|----------|
| 0 | Hello Garden | `ft_hello_garden.js` | `console.log()`, fonctions, exports |
| 1 | Garden Name | `ft_garden_name.js` | `readline-sync`, input/output |
| 2 | Garden Plot Area | `ft_plot_area.js` | `parseInt()`, calcul, variables |
| 3 | Harvest Total | `ft_harvest_total.js` | Additionner des inputs, total |
| 4 | Plant Age Check | `ft_plant_age.js` | Conditions `if/else`, comparaison |
| 5 | Water Reminder | `ft_water_reminder.js` | Conditions, logique |
| 6 | Count to Harvest | `ft_count_harvest_*.js` | Boucles, récursion |
| 7 | Seed Inventory | `ft_seed_inventory.js` | JSDoc, `switch/if`, paramètres |
