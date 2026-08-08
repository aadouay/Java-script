#!/bin/bash
# ╔══════════════════════════════════════════════════════╗
# ║        🌿 MOULINETTE DAY02 — Objects & JSON 🌿       ║
# ║  Teste automatiquement tous les exercices du Day02   ║
# ║  Usage: ./moulinette.sh [ex_number]                  ║
# ║  Ex:    ./moulinette.sh        (tous les exercices)  ║
# ║         ./moulinette.sh 0      (seulement ex00)      ║
# ╚══════════════════════════════════════════════════════╝

set +e

# ── Configuration ──
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TESTER="$SCRIPT_DIR/tester_pro"
EX_DIR="$SCRIPT_DIR/../exercises"

# Couleurs
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
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

# ── Fonction : trouver un fichier ──
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
    #  EX00 — ft_build_access
    # ════════════════════════════════════════
    0)
        local fname="ft_build_access.js"
        local f
        f=$(find_file "$EX_DIR/ex00" "$fname") || { skip_exercise "ex00" "$fname"; return; }
        run_test "color / black" \
            "$f" "__wrap_ex00.js" "ft_build_access(\"color\", \"black\")" \
            "Name: Keyboard\nPrice: 49\n{ name: 'Keyboard', price: 49, inStock: true, color: 'black' }" || ex_status="FAIL"
        run_test "brand / Logitech" \
            "$f" "__wrap_ex00.js" "ft_build_access(\"brand\", \"Logitech\")" \
            "Name: Keyboard\nPrice: 49\n{ name: 'Keyboard', price: 49, inStock: true, brand: 'Logitech' }" || ex_status="FAIL"
        ;;

    # ════════════════════════════════════════
    #  EX01 — ft_list_keys
    # ════════════════════════════════════════
    1)
        local fname="ft_list_keys.js"
        local f
        f=$(find_file "$EX_DIR/ex01" "$fname") || { skip_exercise "ex01" "$fname"; return; }
        run_test "1984 object" \
            "$f" "__wrap_ex01.js" "ft_list_keys({ title: \"1984\", author: \"Orwell\", year: 1949 })" \
            "Property count: 3\nKeys: [ 'title', 'author', 'year' ]" || ex_status="FAIL"
        run_test "empty object" \
            "$f" "__wrap_ex01.js" "ft_list_keys({})" \
            "Property count: 0\nKeys: []" || ex_status="FAIL"
        ;;

    # ════════════════════════════════════════
    #  EX02 — ft_list_values
    # ════════════════════════════════════════
    2)
        local fname="ft_list_values.js"
        local f
        f=$(find_file "$EX_DIR/ex02" "$fname") || { skip_exercise "ex02" "$fname"; return; }
        run_test "1984 object" \
            "$f" "__wrap_ex02.js" "ft_list_values({ title: \"1984\", author: \"Orwell\", year: 1949 })" \
            "Values: [ '1984', 'Orwell', 1949 ]" || ex_status="FAIL"
        run_test "single property" \
            "$f" "__wrap_ex02.js" "ft_list_values({ status: \"active\" })" \
            "Values: [ 'active' ]" || ex_status="FAIL"
        ;;

    # ════════════════════════════════════════
    #  EX03 — ft_entries_report
    # ════════════════════════════════════════
    3)
        local fname="ft_entries_report.js"
        local f
        f=$(find_file "$EX_DIR/ex03" "$fname") || { skip_exercise "ex03" "$fname"; return; }
        run_test "1984 object" \
            "$f" "__wrap_ex03.js" "ft_entries_report({ title: \"1984\", author: \"Orwell\", year: 1949 })" \
            "title: 1984\nauthor: Orwell\nyear: 1949" || ex_status="FAIL"
        run_test "user profile" \
            "$f" "__wrap_ex03.js" "ft_entries_report({ name: \"Alice\", role: \"admin\" })" \
            "name: Alice\nrole: admin" || ex_status="FAIL"
        ;;

    # ════════════════════════════════════════
    #  EX04 — ft_destructure_me
    # ════════════════════════════════════════
    4)
        local fname="ft_destructure_me.js"
        local f
        f=$(find_file "$EX_DIR/ex04" "$fname") || { skip_exercise "ex04" "$fname"; return; }
        run_test "Yassine in Rabat" \
            "$f" "__wrap_ex04.js" "ft_destructure_me({ name: \"Yassine\", age: 25, city: \"Rabat\" })" \
            "Yassine is 25 years old and lives in Rabat." || ex_status="FAIL"
        run_test "Sarah in Paris" \
            "$f" "__wrap_ex04.js" "ft_destructure_me({ name: \"Sarah\", age: 30, city: \"Paris\" })" \
            "Sarah is 30 years old and lives in Paris." || ex_status="FAIL"
        ;;

    # ════════════════════════════════════════
    #  EX05 — ft_merge_profiles
    # ════════════════════════════════════════
    5)
        local fname="ft_merge_profiles.js"
        local f
        f=$(find_file "$EX_DIR/ex05" "$fname") || { skip_exercise "ex05" "$fname"; return; }
        run_test "theme light -> dark" \
            "$f" "__wrap_ex05.js" "ft_merge_profiles({ theme: \"light\", notifications: true }, { theme: \"dark\" })" \
            "{ theme: 'dark', notifications: true }" || ex_status="FAIL"
        run_test "multiple overrides" \
            "$f" "__wrap_ex05.js" "ft_merge_profiles({ a: 1, b: 2 }, { b: 20, c: 3 })" \
            "{ a: 1, b: 20, c: 3 }" || ex_status="FAIL"
        ;;

    # ════════════════════════════════════════
    #  EX06 — ft_to_json
    # ════════════════════════════════════════
    6)
        local fname="ft_to_json.js"
        local f
        f=$(find_file "$EX_DIR/ex06" "$fname") || { skip_exercise "ex06" "$fname"; return; }
        run_test "1984 to JSON" \
            "$f" "__wrap_ex06.js" "ft_to_json({ title: \"1984\", year: 1949 })" \
            "{\"title\":\"1984\",\"year\":1949}\nType: string" || ex_status="FAIL"
        run_test "user to JSON" \
            "$f" "__wrap_ex06.js" "ft_to_json({ name: \"Bob\", active: true })" \
            "{\"name\":\"Bob\",\"active\":true}\nType: string" || ex_status="FAIL"
        ;;

    # ════════════════════════════════════════
    #  EX07 — ft_from_json
    # ════════════════════════════════════════
    7)
        local fname="ft_from_json.js"
        local f
        f=$(find_file "$EX_DIR/ex07" "$fname") || { skip_exercise "ex07" "$fname"; return; }
        run_test "JSON string 1984" \
            "$f" "__wrap_ex07.js" "ft_from_json('{\"title\":\"1984\",\"year\":1949}')" \
            "Type: object\nTitle: 1984" || ex_status="FAIL"
        run_test "JSON string Dune" \
            "$f" "__wrap_ex07.js" "ft_from_json('{\"title\":\"Dune\",\"year\":1965}')" \
            "Type: object\nTitle: Dune" || ex_status="FAIL"
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
echo -e "  ${CYAN}${BOLD}║    🌿 MOULINETTE DAY02 — Objects & JSON 🌿            ║${RESET}"
echo -e "  ${CYAN}${BOLD}║          Tester automatique — Style 42 Paris         ║${RESET}"
echo -e "  ${CYAN}${BOLD}╚══════════════════════════════════════════════════════╝${RESET}\n"

# ── Exécution ──
if [ -n "$1" ]; then
    ex_arg=$1
    echo -e "${BOLD}╔════════════════════════════════════════════╗${RESET}"
    case "$ex_arg" in
        0) echo -e "${BOLD}║  Exercise 0 : Build and Access${RESET}" ;;
        1) echo -e "${BOLD}║  Exercise 1 : List Keys${RESET}" ;;
        2) echo -e "${BOLD}║  Exercise 2 : List Values${RESET}" ;;
        3) echo -e "${BOLD}║  Exercise 3 : Entries Report${RESET}" ;;
        4) echo -e "${BOLD}║  Exercise 4 : Destructure Me${RESET}" ;;
        5) echo -e "${BOLD}║  Exercise 5 : Merge Profiles${RESET}" ;;
        6) echo -e "${BOLD}║  Exercise 6 : To JSON${RESET}" ;;
        7) echo -e "${BOLD}║  Exercise 7 : From JSON${RESET}" ;;
        *) echo -e "${BOLD}║  Exercise $ex_arg${RESET}" ;;
    esac
    echo -e "${BOLD}╚════════════════════════════════════════════╝${RESET}"
    test_exercise "$ex_arg"
else
    for i in 0 1 2 3 4 5 6 7; do
        echo -e "${BOLD}╔════════════════════════════════════════════╗${RESET}"
        case "$i" in
            0) echo -e "${BOLD}║  Exercise 0 : Build and Access${RESET}" ;;
            1) echo -e "${BOLD}║  Exercise 1 : List Keys${RESET}" ;;
            2) echo -e "${BOLD}║  Exercise 2 : List Values${RESET}" ;;
            3) echo -e "${BOLD}║  Exercise 3 : Entries Report${RESET}" ;;
            4) echo -e "${BOLD}║  Exercise 4 : Destructure Me${RESET}" ;;
            5) echo -e "${BOLD}║  Exercise 5 : Merge Profiles${RESET}" ;;
            6) echo -e "${BOLD}║  Exercise 6 : To JSON${RESET}" ;;
            7) echo -e "${BOLD}║  Exercise 7 : From JSON${RESET}" ;;
        esac
        echo -e "${BOLD}╚════════════════════════════════════════════╝${RESET}"
        test_exercise "$i"
        echo ""
    done
fi

# ── Résumé global ──
echo -e "\n  ${CYAN}${BOLD}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "  ${CYAN}${BOLD}║              RÉSUMÉ GLOBAL — DAY02                   ║${RESET}"
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

[ "$TOTAL_FAIL" -eq 0 ]
