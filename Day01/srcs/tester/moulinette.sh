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
        grep -A2 "Attendu :" /tmp/moulinette_out.txt 2>/dev/null | head -4 | sed 's/^/             /'
        grep -A2 "Reçu" /tmp/moulinette_out.txt 2>/dev/null | head -4 | sed 's/^/             /'
        echo -e "  ${DIM}      ────────────────────────────────────────────${RESET}"
        TOTAL_FAIL=$((TOTAL_FAIL + 1))
        return 1
    fi
}

# ── Fonction : trouver un fichier dans un dossier ──
find_file() {
    local dir="$1"
    local name="$2"
    local path="$dir/$name"
    if [ -f "$path" ]; then
        echo "$(cd "$(dirname "$path")" && pwd)/$(basename "$path")"
        return 0
    fi
    return 1
}

# ── Fonction : skip un exercice ──
skip_exercise() {
    local ex="$1"
    local filename="$2"
    echo -e "  ${YELLOW}⚠ SKIP — fichier '$filename' introuvable${RESET}"
    TOTAL_SKIP=$((TOTAL_SKIP + 1))
    EX_RESULTS+=("$ex: ${YELLOW}⚠ SKIP${RESET}")
}

# ── Fonction : tester un exercice complet ──
test_exercise() {
    local ex_num="$1"
    local ex_status="PASS"

    case "$ex_num" in

    # ════════════════════════════════════════
    #  EX00 — ft_slice_split
    # ════════════════════════════════════════
    0)
        local fname="ft_slice_split.js"
        local f
        f=$(find_file "$EX_DIR/ex00" "$fname") || { skip_exercise "ex00" "$fname"; return; }
        run_test "Node handles many requests" \
            "$f" "__wrap_ex00.js" "ft_slice_split(\"Node handles many requests\")" \
            "First word: Node\nWords: [ 'Node', 'handles', 'many', 'requests' ]" || ex_status="FAIL"
        run_test "Hello World" \
            "$f" "__wrap_ex00.js" "ft_slice_split(\"Hello World\")" \
            "First word: Hello\nWords: [ 'Hello', 'World' ]" || ex_status="FAIL"
        run_test "Single word" \
            "$f" "__wrap_ex00.js" "ft_slice_split(\"JavaScript\")" \
            "First word: JavaScript\nWords: [ 'JavaScript' ]" || ex_status="FAIL"
        run_test "Three words" \
            "$f" "__wrap_ex00.js" "ft_slice_split(\"foo bar baz\")" \
            "First word: foo\nWords: [ 'foo', 'bar', 'baz' ]" || ex_status="FAIL"
        run_test "Four words sentence" \
            "$f" "__wrap_ex00.js" "ft_slice_split(\"the quick brown fox\")" \
            "First word: the\nWords: [ 'the', 'quick', 'brown', 'fox' ]" || ex_status="FAIL"
        ;;

    # ════════════════════════════════════════
    #  EX01 — ft_replace_search
    # ════════════════════════════════════════
    1)
        local fname="ft_replace_search.js"
        local f
        f=$(find_file "$EX_DIR/ex01" "$fname") || { skip_exercise "ex01" "$fname"; return; }
        # Vérifie si la fonction est vide (pas encore implémentée)
        local lines
        lines=$(node -e "
const m = require('$f');
const fn = (typeof m === 'function') ? m : (m['ft_replace_search'] || m.default);
if (typeof fn !== 'function') { console.log('NO_EXPORT'); process.exit(1); }
const out = fn('Alice', 'Hello World') || '';
console.log(String(out).length > 0 ? 'HAS_OUTPUT' : 'EMPTY');
" 2>/dev/null)
        if [ "$lines" = "EMPTY" ] || [ "$lines" = "NO_EXPORT" ]; then
            echo -e "  ${YELLOW}⚠ Fonction vide — implémente ft_replace_search d'abord !${RESET}"
            EX_RESULTS+=("ex01: ${YELLOW}⚠ TODO${RESET}")
            return
        fi
        run_test "Sara avec urgent" \
            "$f" "__wrap_ex01.js" "ft_replace_search(\"Sara\", \"urgent error in the server\")" \
            "Hello Sara\nurgent error in the server\nContains \"urgent\" : true" || ex_status="FAIL"
        run_test "Alice sans urgent" \
            "$f" "__wrap_ex01.js" "ft_replace_search(\"Alice\", \"no critical issues\")" \
            "Hello Alice\nno critical issues\nContains \"urgent\" : false" || ex_status="FAIL"
        run_test "Bob message urgent" \
            "$f" "__wrap_ex01.js" "ft_replace_search(\"Bob\", \"this is urgent please fix\")" \
            "Hello Bob\nthis is urgent please fix\nContains \"urgent\" : true" || ex_status="FAIL"
        run_test "name with normal message" \
            "$f" "__wrap_ex01.js" "ft_replace_search(\"Charlie\", \"everything is fine\")" \
            "Hello Charlie\neverything is fine\nContains \"urgent\" : false" || ex_status="FAIL"
        ;;

    # ════════════════════════════════════════
    #  EX02 — ft_array_basics
    # ════════════════════════════════════════
    2)
        local fname="ft_array_basics.js"
        local f
        f=$(find_file "$EX_DIR/ex02" "$fname") || { skip_exercise "ex02" "$fname"; return; }
        run_test "GET POST PUT DELETE" \
            "$f" "__wrap_ex02.js" "ft_array_basics([\"GET\",\"POST\",\"PUT\",\"DELETE\"])" \
            "Length: 4\nFirst : GET\nLast: DELETE" || ex_status="FAIL"
        run_test "Single element" \
            "$f" "__wrap_ex02.js" "ft_array_basics([\"PATCH\"])" \
            "Length: 1\nFirst : PATCH\nLast: PATCH" || ex_status="FAIL"
        run_test "Numbers array [1,2,3]" \
            "$f" "__wrap_ex02.js" "ft_array_basics([1,2,3])" \
            "Length: 3\nFirst : 1\nLast: 3" || ex_status="FAIL"
        run_test "Two elements" \
            "$f" "__wrap_ex02.js" "ft_array_basics([\"hello\",\"world\"])" \
            "Length: 2\nFirst : hello\nLast: world" || ex_status="FAIL"
        run_test "Five HTTP methods" \
            "$f" "__wrap_ex02.js" "ft_array_basics([\"GET\",\"POST\",\"PUT\",\"DELETE\",\"PATCH\"])" \
            "Length: 5\nFirst : GET\nLast: PATCH" || ex_status="FAIL"
        ;;

    # ════════════════════════════════════════
    #  EX03 — ft_stack_queue (Exercice de découverte)
    # ════════════════════════════════════════
    3)
        local fname="ft_stack_queue.js"
        local f
        f=$(find_file "$EX_DIR/ex03" "$fname") || { skip_exercise "ex03" "$fname"; return; }
        echo -e "  ${YELLOW}⚠ Exercice libre : Le sujet ne demande pas d'output spécifique.${RESET}"
        echo -e "  ${DIM}  Objectif : découvrir les méthodes d'Array (push, pop, shift, unshift).${RESET}"
        EX_RESULTS+=("ex03: ${YELLOW}⚠ TODO (Libre)${RESET}")
        return
        ;;

    # ════════════════════════════════════════
    #  EX04 à EX07 — à définir selon le PDF
    # ════════════════════════════════════════
    4|5|6|7)
        local ex_name="ex0$ex_num"
        local exdir="$EX_DIR/$ex_name"
        if [ ! -d "$exdir" ] || [ -z "$(ls -A "$exdir" 2>/dev/null)" ]; then
            echo -e "  ${YELLOW}⚠ SKIP — dossier $ex_name vide ou introuvable${RESET}"
            TOTAL_SKIP=$((TOTAL_SKIP + 1))
            EX_RESULTS+=("$ex_name: ${YELLOW}⚠ SKIP${RESET}")
            return
        fi
        local jsfile=$(ls "$exdir"/*.js 2>/dev/null | head -1)
        if [ -z "$jsfile" ]; then
            echo -e "  ${YELLOW}⚠ SKIP — aucun fichier .js dans $ex_name${RESET}"
            TOTAL_SKIP=$((TOTAL_SKIP + 1))
            EX_RESULTS+=("$ex_name: ${YELLOW}⚠ SKIP${RESET}")
            return
        fi
        echo -e "  ${YELLOW}⚠ $ex_name détecté : $(basename "$jsfile") — tests à définir après implémentation${RESET}"
        EX_RESULTS+=("$ex_name: ${YELLOW}⚠ TODO${RESET}")
        return
        ;;

    *)
        echo -e "  ${RED}Exercice $ex_num inconnu${RESET}"
        return
        ;;
    esac

    # ── Résultat de l'exercice ──
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
    ex_arg=$1
    echo -e "${BOLD}╔════════════════════════════════════════════╗${RESET}"
    case "$ex_arg" in
        0) echo -e "${BOLD}║  Exercise 0 : Slice & Split${RESET}" ;;
        1) echo -e "${BOLD}║  Exercise 1 : Replace & Search${RESET}" ;;
        2) echo -e "${BOLD}║  Exercise 2 : Array Basics${RESET}" ;;
        3) echo -e "${BOLD}║  Exercise 3${RESET}" ;;
        4) echo -e "${BOLD}║  Exercise 4${RESET}" ;;
        5) echo -e "${BOLD}║  Exercise 5${RESET}" ;;
        6) echo -e "${BOLD}║  Exercise 6${RESET}" ;;
        7) echo -e "${BOLD}║  Exercise 7${RESET}" ;;
        *) echo -e "${BOLD}║  Exercise $ex_arg${RESET}" ;;
    esac
    echo -e "${BOLD}╚════════════════════════════════════════════╝${RESET}"
    test_exercise "$ex_arg"
else
    # Tester tous les exercices
    for i in 0 1 2 3 4 5 6 7; do
        echo -e "${BOLD}╔════════════════════════════════════════════╗${RESET}"
        case "$i" in
            0) echo -e "${BOLD}║  Exercise 0 : Slice & Split${RESET}" ;;
            1) echo -e "${BOLD}║  Exercise 1 : Replace & Search${RESET}" ;;
            2) echo -e "${BOLD}║  Exercise 2 : Array Basics${RESET}" ;;
            3) echo -e "${BOLD}║  Exercise 3${RESET}" ;;
            4) echo -e "${BOLD}║  Exercise 4${RESET}" ;;
            5) echo -e "${BOLD}║  Exercise 5${RESET}" ;;
            6) echo -e "${BOLD}║  Exercise 6${RESET}" ;;
            7) echo -e "${BOLD}║  Exercise 7${RESET}" ;;
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
elif [ "$TOTAL_PASS" -eq 0 ] && [ "$TOTAL_FAIL" -eq 0 ]; then
    echo -e "  ${CYAN}${BOLD}║  ${YELLOW}⚠  Aucun fichier soumis — Commence à coder !${RESET}         ${CYAN}${BOLD}║${RESET}"
elif [ "$TOTAL_FAIL" -eq 0 ]; then
    echo -e "  ${CYAN}${BOLD}║  ${YELLOW}⚠  Certains exercices non soumis (SKIP)${RESET}              ${CYAN}${BOLD}║${RESET}"
else
    pct=0
    if [ $((TOTAL_PASS + TOTAL_FAIL)) -gt 0 ]; then
        pct=$(( TOTAL_PASS * 100 / (TOTAL_PASS + TOTAL_FAIL) ))
    fi
    echo -e "  ${CYAN}${BOLD}║  ${RED}✗  MOULINETTE : ${pct}%  — Des tests ont échoué    ✗${RESET}   ${CYAN}${BOLD}║${RESET}"
fi

echo -e "  ${CYAN}${BOLD}╚══════════════════════════════════════════════════════╝${RESET}\n"

# Code de sortie
[ "$TOTAL_FAIL" -eq 0 ]
