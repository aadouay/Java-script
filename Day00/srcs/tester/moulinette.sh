#!/bin/bash
# ╔══════════════════════════════════════════════════════╗
# ║        🔧 MOULINETTE DAY00 — Auto Tester 🔧         ║
# ║  Teste automatiquement tous les exercices du Day00   ║
# ║  Usage: ./moulinette.sh [ex_number]                  ║
# ║  Ex:    ./moulinette.sh        (tous les exercices)  ║
# ║         ./moulinette.sh 1      (seulement ex01)      ║
# ╚══════════════════════════════════════════════════════╝

# Don't exit on test failures
set +e

# ── Configuration ──
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TESTER="$SCRIPT_DIR/tester_pro"
EX_DIR="$SCRIPT_DIR/../exercises"

# Couleurs
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
CYAN='\033[36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# Compteurs globaux
TOTAL_PASS=0
TOTAL_FAIL=0
TOTAL_SKIP=0
EX_RESULTS=()

# ── Vérifier les prérequis (node et g++) ──
if ! command -v node >/dev/null 2>&1; then
    echo -e "${RED}❌ Erreur : 'node' n'est pas installé sur cette machine !${RESET}"
    exit 1
fi

# ── Recompiler le tester s'il n'existe pas, s'il est périmé, ou s'il ne s'exécute pas ──
if [ ! -f "$TESTER" ] || [ "$SCRIPT_DIR/tester_pro.cpp" -nt "$TESTER" ] || ! "$TESTER" --help >/dev/null 2>&1; then
    if ! command -v g++ >/dev/null 2>&1; then
        echo -e "${RED}❌ Erreur : 'g++' n'est pas installé sur cette machine pour compiler le tester !${RESET}"
        exit 1
    fi
    echo -e "${YELLOW}⚙ Compilation du tester pour cette machine...${RESET}"
    rm -f "$TESTER"
    g++ -std=c++17 -o "$TESTER" "$SCRIPT_DIR/tester_pro.cpp"
    chmod +x "$TESTER"
    echo -e "${GREEN}✓ Tester compilé avec succès.${RESET}\n"
fi

# ── Fonction utilitaire : lancer un test ──
run_test() {
    local label="$1"
    shift
    echo -e "  ${DIM}─── $label ───${RESET}"
    if "$TESTER" "$@" > /tmp/moulinette_out.txt 2>&1; then
        echo -e "  ${GREEN}✓ PASS${RESET} — $label"
        TOTAL_PASS=$((TOTAL_PASS + 1))
        return 0
    else
        echo -e "  ${RED}✗ FAIL${RESET} — $label"
        # Afficher le diff attendu/reçu
        grep -A2 "Attendu :" /tmp/moulinette_out.txt 2>/dev/null | head -3 | sed 's/^/    /'
        grep -A2 "Stderr" /tmp/moulinette_out.txt 2>/dev/null | head -3 | sed 's/^/    /'
        TOTAL_FAIL=$((TOTAL_FAIL + 1))
        return 1
    fi
}

# ── Fonction : tester un exercice complet ──
test_exercise() {
    local ex_num="$1"
    local ex_name="$2"
    local ex_status="PASS"

    echo ""
    echo -e "${BOLD}${BLUE}╔════════════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}${BLUE}║  Exercise $ex_num : $ex_name${RESET}"
    echo -e "${BOLD}${BLUE}╚════════════════════════════════════════════╝${RESET}"

    local before_pass=$TOTAL_PASS
    local before_fail=$TOTAL_FAIL

    case "$ex_num" in
    # ════════════════════════════════════════
    #  EX00 — Hello Garden (wrapper mode)
    # ════════════════════════════════════════
    0)
        local f="$EX_DIR/ex00/ft_hello_garden.js"
        if [ ! -f "$f" ]; then
            echo -e "  ${YELLOW}⚠ SKIP — fichier introuvable${RESET}"
            TOTAL_SKIP=$((TOTAL_SKIP + 1))
            EX_RESULTS+=("ex00: ${YELLOW}SKIP${RESET}")
            return
        fi
        # Use absolute path for wrapper mode
        local abs_f="$(cd "$(dirname "$f")" && pwd)/$(basename "$f")"
        run_test "Test basique" "$abs_f" "__wrap_ex00.js" "ft_hello_garden()" "Hello , Garden Community !" || ex_status="FAIL"
        ;;

    # ════════════════════════════════════════
    #  EX01 — Garden Name (wrapper or direct + stdin)
    # ════════════════════════════════════════
    1)
        local f="$EX_DIR/ex01/ft_garden_name.js"
        if [ ! -f "$f" ]; then
            echo -e "  ${YELLOW}⚠ SKIP — fichier introuvable${RESET}"
            TOTAL_SKIP=$((TOTAL_SKIP + 1))
            EX_RESULTS+=("ex01: ${YELLOW}SKIP${RESET}")
            return
        fi
        local abs_f="$(cd "$(dirname "$f")" && pwd)/$(basename "$f")"
        if grep -q "module.exports" "$f"; then
            run_test "Input: Community Garden" \
                --stdin "Community Garden" "$abs_f" "__wrap_ex01.js" "garden_name()" \
                "Enter garden name : Garden : Community Garden\nStatus : Growing well !" || \
            run_test "Input: Community Garden (ft_garden_name)" \
                --stdin "Community Garden" "$abs_f" "__wrap_ex01.js" "ft_garden_name()" \
                "Enter garden name : Garden : Community Garden\nStatus : Growing well !" || ex_status="FAIL"

            run_test "Input: Roses" \
                --stdin "Roses" "$abs_f" "__wrap_ex01.js" "garden_name()" \
                "Enter garden name : Garden : Roses\nStatus : Growing well !" || \
            run_test "Input: Roses (ft_garden_name)" \
                --stdin "Roses" "$abs_f" "__wrap_ex01.js" "ft_garden_name()" \
                "Enter garden name : Garden : Roses\nStatus : Growing well !" || ex_status="FAIL"
        else
            run_test "Input: Community Garden (direct)" \
                --direct --stdin "Community Garden" "$f" \
                "Enter garden name : Garden : Community Garden\nStatus : Growing well !" || ex_status="FAIL"
            run_test "Input: Roses (direct)" \
                --direct --stdin "Roses" "$f" \
                "Enter garden name : Garden : Roses\nStatus : Growing well !" || ex_status="FAIL"
        fi
        ;;

    # ════════════════════════════════════════
    #  EX02 — Garden Plot Area (wrapper + stdin)
    # ════════════════════════════════════════
    2)
        local f="$EX_DIR/ex02/ft_plot_area.js"
        if [ ! -f "$f" ]; then
            echo -e "  ${YELLOW}⚠ SKIP — fichier introuvable${RESET}"
            TOTAL_SKIP=$((TOTAL_SKIP + 1))
            EX_RESULTS+=("ex02: ${YELLOW}SKIP${RESET}")
            return
        fi
        local abs_f="$(cd "$(dirname "$f")" && pwd)/$(basename "$f")"
        run_test "5 x 3 = 15" \
            --stdin "5\n3" "$abs_f" "__wrap_ex02.js" "ft_plot_area()" \
            "Enter length: Enter width: Plot area : 15" || \
        run_test "5 x 3 = 15 (avec espace)" \
            --stdin "5\n3" "$abs_f" "__wrap_ex02.js" "ft_plot_area()" \
            "Enter length : Enter width : Plot area : 15" || ex_status="FAIL"

        run_test "10 x 10 = 100" \
            --stdin "10\n10" "$abs_f" "__wrap_ex02.js" "ft_plot_area()" \
            "Enter length: Enter width: Plot area : 100" || \
        run_test "10 x 10 = 100 (avec espace)" \
            --stdin "10\n10" "$abs_f" "__wrap_ex02.js" "ft_plot_area()" \
            "Enter length : Enter width : Plot area : 100" || ex_status="FAIL"
        ;;

    # ════════════════════════════════════════
    #  EX03 — Harvest Total (wrapper + stdin)
    # ════════════════════════════════════════
    3)
        local f="$EX_DIR/ex03/ft_harvest_total.js"
        if [ ! -f "$f" ]; then
            echo -e "  ${YELLOW}⚠ SKIP — fichier introuvable${RESET}"
            TOTAL_SKIP=$((TOTAL_SKIP + 1))
            EX_RESULTS+=("ex03: ${YELLOW}SKIP${RESET}")
            return
        fi
        local abs_f="$(cd "$(dirname "$f")" && pwd)/$(basename "$f")"
        run_test "5+8+3=16" \
            --stdin "5\n8\n3" "$abs_f" "__wrap_ex03.js" "ft_harvest_total()" \
            "Day 1 harvest : Day 2 harvest : Day 3 harvest : Total harvest : 16" || ex_status="FAIL"
        run_test "10+20+30=60" \
            --stdin "10\n20\n30" "$abs_f" "__wrap_ex03.js" "ft_harvest_total()" \
            "Day 1 harvest : Day 2 harvest : Day 3 harvest : Total harvest : 60" || ex_status="FAIL"
        ;;

    # ════════════════════════════════════════
    #  EX04 — Plant Age Check (wrapper + stdin)
    # ════════════════════════════════════════
    4)
        local f="$EX_DIR/ex04/ft_plant_age.js"
        if [ ! -f "$f" ]; then
            echo -e "  ${YELLOW}⚠ SKIP — fichier introuvable${RESET}"
            TOTAL_SKIP=$((TOTAL_SKIP + 1))
            EX_RESULTS+=("ex04: ${YELLOW}SKIP${RESET}")
            return
        fi
        local abs_f="$(cd "$(dirname "$f")" && pwd)/$(basename "$f")"
        run_test "75 jours (ready)" \
            --stdin "75" "$abs_f" "__wrap_ex04.js" "ft_plant_age()" \
            "Enter plant age in days : Plant is ready to harvest !" || ex_status="FAIL"
        run_test "30 jours (not ready)" \
            --stdin "30" "$abs_f" "__wrap_ex04.js" "ft_plant_age()" \
            "Enter plant age in days : Plant is not ready yet." || ex_status="FAIL"
        ;;

    # ════════════════════════════════════════
    #  EX05 — Water Reminder (wrapper + stdin)
    # ════════════════════════════════════════
    5)
        local f="$EX_DIR/ex05/ft_water_reminder.js"
        if [ ! -f "$f" ]; then
            echo -e "  ${YELLOW}⚠ SKIP — fichier introuvable${RESET}"
            TOTAL_SKIP=$((TOTAL_SKIP + 1))
            EX_RESULTS+=("ex05: ${YELLOW}SKIP${RESET}")
            return
        fi
        local abs_f="$(cd "$(dirname "$f")" && pwd)/$(basename "$f")"
        run_test "3 jours (water!)" \
            --stdin "3" "$abs_f" "__wrap_ex05.js" "ft_water_reminder()" \
            "Days since last watering : Water the plants!" || ex_status="FAIL"
        run_test "1 jour (fine)" \
            --stdin "1" "$abs_f" "__wrap_ex05.js" "ft_water_reminder()" \
            "Days since last watering : Plants are fine." || ex_status="FAIL"
        ;;

    # ════════════════════════════════════════
    #  EX06 — Count to Harvest (iterative + recursive)
    # ════════════════════════════════════════
    6)
        local f1="$EX_DIR/ex06/ft_count_harvest_iterative.js"
        local f2="$EX_DIR/ex06/ft_count_harvest_recursive.js"
        if [ ! -f "$f1" ] && [ ! -f "$f2" ]; then
            echo -e "  ${YELLOW}⚠ SKIP — fichiers introuvables${RESET}"
            TOTAL_SKIP=$((TOTAL_SKIP + 1))
            EX_RESULTS+=("ex06: ${YELLOW}SKIP${RESET}")
            return
        fi
        if [ -f "$f1" ]; then
            local abs_f1="$(cd "$(dirname "$f1")" && pwd)/$(basename "$f1")"
            run_test "Iterative: 5 jours" \
                --stdin "5" "$abs_f1" "__wrap_ex06_iter.js" "ft_count_harvest_iterative()" \
                "Days until harvest : Day 1\nDay 2\nDay 3\nDay 4\nDay 5\nHarvest time !" || ex_status="FAIL"
        fi
        if [ -f "$f2" ]; then
            local abs_f2="$(cd "$(dirname "$f2")" && pwd)/$(basename "$f2")"
            run_test "Recursive: 5 jours" \
                --stdin "5" "$abs_f2" "__wrap_ex06_rec.js" "ft_count_harvest_recursive()" \
                "Days until harvest : Day 1\nDay 2\nDay 3\nDay 4\nDay 5\nHarvest time !" || ex_status="FAIL"
        fi
        ;;

    # ════════════════════════════════════════
    #  EX07 — Seed Inventory (wrapper mode)
    # ════════════════════════════════════════
    7)
        local f="$EX_DIR/ex07/ft_seed_inventory.js"
        if [ ! -f "$f" ]; then
            echo -e "  ${YELLOW}⚠ SKIP — fichier introuvable${RESET}"
            TOTAL_SKIP=$((TOTAL_SKIP + 1))
            EX_RESULTS+=("ex07: ${YELLOW}SKIP${RESET}")
            return
        fi
        local abs_f="$(cd "$(dirname "$f")" && pwd)/$(basename "$f")"
        run_test "packets (Tomato)" \
            "$abs_f" "__wrap_ex07.js" \
            "ft_seed_inventory(\"Tomato\", 15, \"packets\")" \
            "Tomato seeds: 15 packets available." || ex_status="FAIL"
        run_test "grams (Carrot)" \
            "$abs_f" "__wrap_ex07.js" \
            "ft_seed_inventory(\"Carrot\", 8, \"grams\")" \
            "Carrot seeds: 8 grams total" || ex_status="FAIL"
        run_test "area (Lettuce)" \
            "$abs_f" "__wrap_ex07.js" \
            "ft_seed_inventory(\"Lettuce\", 12, \"area\")" \
            "Lettuce seeds: covers 12 square meters" || ex_status="FAIL"
        run_test "unknown unit" \
            "$abs_f" "__wrap_ex07.js" \
            "ft_seed_inventory(\"Basil\", 5, \"liters\")" \
            "Unknown unit type" || ex_status="FAIL"
        ;;
    esac

    local this_pass=$((TOTAL_PASS - before_pass))
    local this_fail=$((TOTAL_FAIL - before_fail))
    local this_total=$((this_pass + this_fail))

    if [ "$ex_status" = "PASS" ]; then
        EX_RESULTS+=("ex0${ex_num}: ${GREEN}✓ PASS${RESET} ($this_pass/$this_total)")
    else
        EX_RESULTS+=("ex0${ex_num}: ${RED}✗ FAIL${RESET} ($this_pass/$this_total)")
    fi
}

# ═══════════════════════════════════════
#              HEADER
# ═══════════════════════════════════════

echo ""
echo -e "${BOLD}${CYAN}  ╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}${CYAN}  ║         🌱 MOULINETTE DAY00 — Growing Code 🌱       ║${RESET}"
echo -e "${BOLD}${CYAN}  ║          Tester automatique — Style 42 Paris         ║${RESET}"
echo -e "${BOLD}${CYAN}  ╚══════════════════════════════════════════════════════╝${RESET}"

# ═══════════════════════════════════════
#         EXÉCUTION DES TESTS
# ═══════════════════════════════════════

if [ -n "$1" ]; then
    # Tester un seul exercice
    case "$1" in
        0) test_exercise 0 "Hello Garden" ;;
        1) test_exercise 1 "Garden Name" ;;
        2) test_exercise 2 "Garden Plot Area" ;;
        3) test_exercise 3 "Harvest Total" ;;
        4) test_exercise 4 "Plant Age Check" ;;
        5) test_exercise 5 "Water Reminder" ;;
        6) test_exercise 6 "Count to Harvest" ;;
        7) test_exercise 7 "Seed Inventory" ;;
        *) echo -e "${RED}Exercice $1 inconnu (0-7)${RESET}"; exit 1 ;;
    esac
else
    # Tester tous les exercices
    test_exercise 0 "Hello Garden"
    test_exercise 1 "Garden Name"
    test_exercise 2 "Garden Plot Area"
    test_exercise 3 "Harvest Total"
    test_exercise 4 "Plant Age Check"
    test_exercise 5 "Water Reminder"
    test_exercise 6 "Count to Harvest"
    test_exercise 7 "Seed Inventory"
fi

# ═══════════════════════════════════════
#           RÉSUMÉ GLOBAL
# ═══════════════════════════════════════

TOTAL=$((TOTAL_PASS + TOTAL_FAIL))

echo ""
echo -e "${BOLD}${CYAN}  ╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}${CYAN}  ║              RÉSUMÉ GLOBAL — DAY00                   ║${RESET}"
echo -e "${BOLD}${CYAN}  ╠══════════════════════════════════════════════════════╣${RESET}"

for r in "${EX_RESULTS[@]}"; do
    echo -e "${BOLD}  ║  $r${RESET}"
done

echo -e "${BOLD}${CYAN}  ╠══════════════════════════════════════════════════════╣${RESET}"
echo -e "${BOLD}  ║  Total tests : $TOTAL${RESET}"
echo -e "${BOLD}  ║  ${GREEN}Passés${RESET}${BOLD} : $TOTAL_PASS${RESET}"
echo -e "${BOLD}  ║  ${RED}Échoués${RESET}${BOLD} : $TOTAL_FAIL${RESET}"
if [ "$TOTAL_SKIP" -gt 0 ]; then
    echo -e "${BOLD}  ║  ${YELLOW}Skippés${RESET}${BOLD} : $TOTAL_SKIP${RESET}"
fi
echo -e "${BOLD}${CYAN}  ╠══════════════════════════════════════════════════════╣${RESET}"

if [ "$TOTAL_FAIL" -eq 0 ] && [ "$TOTAL_SKIP" -eq 0 ]; then
    echo -e "${BOLD}  ║  ${GREEN}★  MOULINETTE : 100%  — TOUS LES TESTS PASSENT  ★${RESET}${BOLD}   ║${RESET}"
elif [ "$TOTAL_FAIL" -eq 0 ]; then
    echo -e "${BOLD}  ║  ${YELLOW}⚠  Certains exercices non soumis (SKIP)          ${RESET}${BOLD}   ║${RESET}"
else
    PCT=$((TOTAL_PASS * 100 / TOTAL))
    echo -e "${BOLD}  ║  ${RED}✗  MOULINETTE : ${PCT}%  — Des tests ont échoué    ✗${RESET}${BOLD}   ║${RESET}"
fi

echo -e "${BOLD}${CYAN}  ╚══════════════════════════════════════════════════════╝${RESET}"
echo ""

# Cleanup
rm -f /tmp/moulinette_out.txt

[ "$TOTAL_FAIL" -eq 0 ] && exit 0 || exit 1
