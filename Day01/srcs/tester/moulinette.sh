#!/bin/bash
# ╔══════════════════════════════════════════════════════╗
# ║        🌱 MOULINETTE DAY01 — Array & String 🌱       ║
# ║  Teste automatiquement tous les exercices du Day01   ║
# ║  Usage: ./moulinette.sh [ex_number]                  ║
# ║  Ex:    ./moulinette.sh        (tous les exercices)  ║
# ║         ./moulinette.sh 0      (seulement ex00)      ║
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

# ── Vérifier que le tester est compilé ──
if [ ! -f "$TESTER" ]; then
    echo -e "${YELLOW}⚙ Compilation du tester...${RESET}"
    g++ -std=c++17 -o "$TESTER" "$SCRIPT_DIR/tester_pro.cpp"
    echo -e "${GREEN}✓ Tester compilé.${RESET}\n"
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
        grep -A2 "Attendu :" /tmp/moulinette_out.txt 2>/dev/null | head -4 | sed 's/^/    /'
        grep -A2 "Stderr" /tmp/moulinette_out.txt 2>/dev/null | head -3 | sed 's/^/    /'
        TOTAL_FAIL=$((TOTAL_FAIL + 1))
        return 1
    fi
}

# ── Fonction : tester un exercice complet ──
test_exercise() {
    local ex_num="$1"
    local ex_status="PASS"

    case "$ex_num" in

    # ════════════════════════════════════════
    #  EX00 — Slice & Split
    # ════════════════════════════════════════
    0)
        local f="$EX_DIR/ex00/ft_slice_split.js"
        if [ ! -f "$f" ]; then
            echo -e "  ${YELLOW}⚠ SKIP — fichier introuvable${RESET}"
            TOTAL_SKIP=$((TOTAL_SKIP + 1))
            EX_RESULTS+=("ex00: ${YELLOW}SKIP${RESET}")
            return
        fi
        local abs_f="$(cd "$(dirname "$f")" && pwd)/$(basename "$f")"
        run_test "Node handles many requests" \
            "$abs_f" "__wrap_ex00.js" "ft_slice_split(\"Node handles many requests\")" \
            "First word: Node\nWords: [ 'Node', 'handles', 'many', 'requests' ]" || ex_status="FAIL"
        run_test "Hello World" \
            "$abs_f" "__wrap_ex00.js" "ft_slice_split(\"Hello World\")" \
            "First word: Hello\nWords: [ 'Hello', 'World' ]" || ex_status="FAIL"
        run_test "Single word" \
            "$abs_f" "__wrap_ex00.js" "ft_slice_split(\"JavaScript\")" \
            "First word: JavaScript\nWords: [ 'JavaScript' ]" || ex_status="FAIL"
        ;;

    # ════════════════════════════════════════
    #  EX01 — Map (transformer un tableau)
    # ════════════════════════════════════════
    1)
        local f="$EX_DIR/ex01/ft_map.js"
        if [ ! -f "$f" ]; then
            echo -e "  ${YELLOW}⚠ SKIP — fichier introuvable${RESET}"
            TOTAL_SKIP=$((TOTAL_SKIP + 1))
            EX_RESULTS+=("ex01: ${YELLOW}SKIP${RESET}")
            return
        fi
        local abs_f="$(cd "$(dirname "$f")" && pwd)/$(basename "$f")"
        run_test "doubler les nombres" \
            "$abs_f" "__wrap_ex01.js" "ft_map([1,2,3], n => n * 2)" \
            "2,4,6" || ex_status="FAIL"
        run_test "mettre en majuscules" \
            "$abs_f" "__wrap_ex01.js" "ft_map([\"hello\",\"world\"], s => s.toUpperCase())" \
            "HELLO,WORLD" || ex_status="FAIL"
        run_test "tableau vide" \
            "$abs_f" "__wrap_ex01.js" "ft_map([], n => n)" \
            "" || ex_status="FAIL"
        ;;

    # ════════════════════════════════════════
    #  EX02 — Filter (filtrer un tableau)
    # ════════════════════════════════════════
    2)
        local f="$EX_DIR/ex02/ft_filter.js"
        if [ ! -f "$f" ]; then
            echo -e "  ${YELLOW}⚠ SKIP — fichier introuvable${RESET}"
            TOTAL_SKIP=$((TOTAL_SKIP + 1))
            EX_RESULTS+=("ex02: ${YELLOW}SKIP${RESET}")
            return
        fi
        local abs_f="$(cd "$(dirname "$f")" && pwd)/$(basename "$f")"
        run_test "nombres pairs" \
            "$abs_f" "__wrap_ex02.js" "ft_filter([1,2,3,4,5,6], n => n % 2 === 0)" \
            "2,4,6" || ex_status="FAIL"
        run_test "nombres > 3" \
            "$abs_f" "__wrap_ex02.js" "ft_filter([1,2,3,4,5], n => n > 3)" \
            "4,5" || ex_status="FAIL"
        run_test "aucun résultat" \
            "$abs_f" "__wrap_ex02.js" "ft_filter([1,2,3], n => n > 10)" \
            "" || ex_status="FAIL"
        ;;

    # ════════════════════════════════════════
    #  EX03 — Reduce (accumuler en une valeur)
    # ════════════════════════════════════════
    3)
        local f="$EX_DIR/ex03/ft_reduce.js"
        if [ ! -f "$f" ]; then
            echo -e "  ${YELLOW}⚠ SKIP — fichier introuvable${RESET}"
            TOTAL_SKIP=$((TOTAL_SKIP + 1))
            EX_RESULTS+=("ex03: ${YELLOW}SKIP${RESET}")
            return
        fi
        local abs_f="$(cd "$(dirname "$f")" && pwd)/$(basename "$f")"
        run_test "somme [1,2,3,4]" \
            "$abs_f" "__wrap_ex03.js" "ft_reduce([1,2,3,4], (acc, n) => acc + n, 0)" \
            "10" || ex_status="FAIL"
        run_test "produit [1,2,3,4]" \
            "$abs_f" "__wrap_ex03.js" "ft_reduce([1,2,3,4], (acc, n) => acc * n, 1)" \
            "24" || ex_status="FAIL"
        ;;

    # ════════════════════════════════════════
    #  EX04 — forEach (itérer sans retour)
    # ════════════════════════════════════════
    4)
        local f="$EX_DIR/ex04/ft_forEach.js"
        if [ ! -f "$f" ]; then
            echo -e "  ${YELLOW}⚠ SKIP — fichier introuvable${RESET}"
            TOTAL_SKIP=$((TOTAL_SKIP + 1))
            EX_RESULTS+=("ex04: ${YELLOW}SKIP${RESET}")
            return
        fi
        local abs_f="$(cd "$(dirname "$f")" && pwd)/$(basename "$f")"
        run_test "afficher chaque élément" \
            "$abs_f" "__wrap_ex04.js" "ft_forEach([\"apple\",\"banana\",\"cherry\"])" \
            "apple\nbanana\ncherry" || ex_status="FAIL"
        run_test "tableau vide" \
            "$abs_f" "__wrap_ex04.js" "ft_forEach([])" \
            "" || ex_status="FAIL"
        ;;

    # ════════════════════════════════════════
    #  EX05 — join & split (conversion)
    # ════════════════════════════════════════
    5)
        local f="$EX_DIR/ex05/ft_join_split.js"
        if [ ! -f "$f" ]; then
            echo -e "  ${YELLOW}⚠ SKIP — fichier introuvable${RESET}"
            TOTAL_SKIP=$((TOTAL_SKIP + 1))
            EX_RESULTS+=("ex05: ${YELLOW}SKIP${RESET}")
            return
        fi
        local abs_f="$(cd "$(dirname "$f")" && pwd)/$(basename "$f")"
        run_test "join avec tiret" \
            "$abs_f" "__wrap_ex05.js" "ft_join_split([\"a\",\"b\",\"c\"], \"-\")" \
            "a-b-c" || ex_status="FAIL"
        run_test "split et rejoindre" \
            "$abs_f" "__wrap_ex05.js" "ft_join_split(\"hello world\", \" \")" \
            "hello,world" || ex_status="FAIL"
        ;;

    # ════════════════════════════════════════
    #  EX06 — find & includes
    # ════════════════════════════════════════
    6)
        local f="$EX_DIR/ex06/ft_find.js"
        if [ ! -f "$f" ]; then
            echo -e "  ${YELLOW}⚠ SKIP — fichier introuvable${RESET}"
            TOTAL_SKIP=$((TOTAL_SKIP + 1))
            EX_RESULTS+=("ex06: ${YELLOW}SKIP${RESET}")
            return
        fi
        local abs_f="$(cd "$(dirname "$f")" && pwd)/$(basename "$f")"
        run_test "find premier > 3" \
            "$abs_f" "__wrap_ex06.js" "ft_find([1,2,3,4,5], n => n > 3)" \
            "4" || ex_status="FAIL"
        run_test "includes true" \
            "$abs_f" "__wrap_ex06.js" "ft_find([\"a\",\"b\",\"c\"], \"b\")" \
            "true" || ex_status="FAIL"
        ;;

    # ════════════════════════════════════════
    #  EX07 — flat & flatMap
    # ════════════════════════════════════════
    7)
        local f="$EX_DIR/ex07/ft_flat.js"
        if [ ! -f "$f" ]; then
            echo -e "  ${YELLOW}⚠ SKIP — fichier introuvable${RESET}"
            TOTAL_SKIP=$((TOTAL_SKIP + 1))
            EX_RESULTS+=("ex07: ${YELLOW}SKIP${RESET}")
            return
        fi
        local abs_f="$(cd "$(dirname "$f")" && pwd)/$(basename "$f")"
        run_test "flat tableau imbriqué" \
            "$abs_f" "__wrap_ex07.js" "ft_flat([[1,2],[3,4],[5]])" \
            "1,2,3,4,5" || ex_status="FAIL"
        run_test "flatMap doubler" \
            "$abs_f" "__wrap_ex07.js" "ft_flat([1,2,3], n => [n, n*2])" \
            "1,2,2,4,3,6" || ex_status="FAIL"
        ;;

    *)
        echo -e "  ${RED}Exercice $ex_num inconnu${RESET}"
        return
        ;;
    esac

    # ── Résultat de l'exercice ──
    local pass_count=$((TOTAL_PASS))
    if [ "$ex_status" = "PASS" ]; then
        EX_RESULTS+=("ex0$ex_num: ${GREEN}✓ PASS${RESET}")
    else
        EX_RESULTS+=("ex0$ex_num: ${RED}✗ FAIL${RESET}")
    fi
}

# ── Bannière ──
echo -e "\n  ${CYAN}${BOLD}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "  ${CYAN}${BOLD}║     🌱 MOULINETTE DAY01 — Array & String 🌱          ║${RESET}"
echo -e "  ${CYAN}${BOLD}║          Tester automatique — Style 42 Paris         ║${RESET}"
echo -e "  ${CYAN}${BOLD}╚══════════════════════════════════════════════════════╝${RESET}\n"

# ── Exécution ──
if [ -n "$1" ]; then
    # Tester un seul exercice
    local_ex=$1
    echo -e "${BOLD}╔════════════════════════════════════════════╗${RESET}"
    case "$local_ex" in
        0) echo -e "${BOLD}║  Exercise 0 : Slice & Split${RESET}" ;;
        1) echo -e "${BOLD}║  Exercise 1 : Map${RESET}" ;;
        2) echo -e "${BOLD}║  Exercise 2 : Filter${RESET}" ;;
        3) echo -e "${BOLD}║  Exercise 3 : Reduce${RESET}" ;;
        4) echo -e "${BOLD}║  Exercise 4 : forEach${RESET}" ;;
        5) echo -e "${BOLD}║  Exercise 5 : Join & Split${RESET}" ;;
        6) echo -e "${BOLD}║  Exercise 6 : Find & Includes${RESET}" ;;
        7) echo -e "${BOLD}║  Exercise 7 : Flat & FlatMap${RESET}" ;;
    esac
    echo -e "${BOLD}╚════════════════════════════════════════════╝${RESET}"
    test_exercise "$local_ex"
else
    # Tester tous les exercices
    for i in 0 1 2 3 4 5 6 7; do
        echo -e "${BOLD}╔════════════════════════════════════════════╗${RESET}"
        case "$i" in
            0) echo -e "${BOLD}║  Exercise 0 : Slice & Split${RESET}" ;;
            1) echo -e "${BOLD}║  Exercise 1 : Map${RESET}" ;;
            2) echo -e "${BOLD}║  Exercise 2 : Filter${RESET}" ;;
            3) echo -e "${BOLD}║  Exercise 3 : Reduce${RESET}" ;;
            4) echo -e "${BOLD}║  Exercise 4 : forEach${RESET}" ;;
            5) echo -e "${BOLD}║  Exercise 5 : Join & Split${RESET}" ;;
            6) echo -e "${BOLD}║  Exercise 6 : Find & Includes${RESET}" ;;
            7) echo -e "${BOLD}║  Exercise 7 : Flat & FlatMap${RESET}" ;;
        esac
        echo -e "${BOLD}╚════════════════════════════════════════════╝${RESET}"
        test_exercise "$i"
        echo ""
    done
fi

# ── Résumé global ──
echo -e "\n  ${CYAN}${BOLD}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "  ${CYAN}${BOLD}║              RÉSUMÉ GLOBAL — DAY01                   ║${RESET}"
echo -e "  ${CYAN}${BOLD}╠══════════════════════════════════════════════════════╣${RESET}"
for result in "${EX_RESULTS[@]}"; do
    echo -e "  ${CYAN}${BOLD}║${RESET}  $result"
done
echo -e "  ${CYAN}${BOLD}╠══════════════════════════════════════════════════════╣${RESET}"
echo -e "  ${CYAN}${BOLD}║${RESET}  Total tests : $((TOTAL_PASS + TOTAL_FAIL))"
echo -e "  ${CYAN}${BOLD}║${RESET}  Passés      : ${GREEN}$TOTAL_PASS${RESET}"
echo -e "  ${CYAN}${BOLD}║${RESET}  Échoués     : ${RED}$TOTAL_FAIL${RESET}"
if [ "$TOTAL_SKIP" -gt 0 ]; then
    echo -e "  ${CYAN}${BOLD}║${RESET}  Skippés     : ${YELLOW}$TOTAL_SKIP${RESET}"
fi
echo -e "  ${CYAN}${BOLD}╠══════════════════════════════════════════════════════╣${RESET}"

if [ "$TOTAL_FAIL" -eq 0 ] && [ "$TOTAL_PASS" -gt 0 ]; then
    echo -e "  ${CYAN}${BOLD}║  ${GREEN}★  MOULINETTE : 100%  — TOUS LES TESTS PASSENT  ★${RESET}   ${CYAN}${BOLD}║${RESET}"
elif [ "$TOTAL_PASS" -eq 0 ] && [ "$TOTAL_SKIP" -gt 0 ]; then
    echo -e "  ${CYAN}${BOLD}║  ${YELLOW}⚠  Aucun fichier soumis — Commence à coder !${RESET}        ${CYAN}${BOLD}║${RESET}"
elif [ "$TOTAL_SKIP" -gt 0 ] && [ "$TOTAL_FAIL" -eq 0 ]; then
    echo -e "  ${CYAN}${BOLD}║  ${YELLOW}⚠  Certains exercices non soumis (SKIP)${RESET}             ${CYAN}${BOLD}║${RESET}"
else
    local pct=0
    if [ $((TOTAL_PASS + TOTAL_FAIL)) -gt 0 ]; then
        pct=$(( TOTAL_PASS * 100 / (TOTAL_PASS + TOTAL_FAIL) ))
    fi
    echo -e "  ${CYAN}${BOLD}║  ${RED}✗  MOULINETTE : ${pct}%  — Des tests ont échoué    ✗${RESET}   ${CYAN}${BOLD}║${RESET}"
fi

echo -e "  ${CYAN}${BOLD}╚══════════════════════════════════════════════════════╝${RESET}\n"

# Code de sortie
[ "$TOTAL_FAIL" -eq 0 ]
