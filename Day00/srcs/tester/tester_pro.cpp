/*
** ╔══════════════════════════════════════════════════════════════════╗
** ║                    TESTER PRO v2.0 - Moulinette JS              ║
** ║                                                                  ║
** ║  Tests effectués :                                               ║
** ║    ✓ Existence du fichier                                        ║
** ║    ✓ Vérification de module.exports (mode wrapper)               ║
** ║    ✓ Comparaison de la sortie (stdout)                           ║
** ║    ✓ Détection de crash / segfault (signaux SIGSEGV, SIGABRT)    ║
** ║    ✓ Détection de timeout (boucle infinie)                       ║
** ║    ✓ Capture de stderr (erreurs de syntaxe, exceptions)          ║
** ║    ✓ Vérification du code de sortie (exit code)                  ║
** ║    ✓ Support stdin (readline-sync, input simulé)       [NEW v2]  ║
** ║    ✓ Mode direct (pas de wrapper nécessaire)           [NEW v2]  ║
** ║                                                                  ║
** ║  Modes d'usage :                                                 ║
** ║                                                                  ║
** ║  MODE WRAPPER (classique, avec module.exports) :                 ║
** ║    ./tester_pro <ex_file> <wrapper> <func_call> <expected>       ║
** ║                                                                  ║
** ║  MODE DIRECT (exécute le fichier tel quel) :                     ║
** ║    ./tester_pro --direct <ex_file> <expected>                    ║
** ║                                                                  ║
** ║  MODE DIRECT + STDIN (pour readline-sync) :                      ║
** ║    ./tester_pro --direct --stdin "input" <ex_file> <expected>    ║
** ║                                                                  ║
** ║  Note : Dans <expected>, utiliser \n pour les retours à la ligne ║
** ╚══════════════════════════════════════════════════════════════════╝
*/

#include <iostream>
#include <string>
#include <sstream>
#include <fstream>
#include <filesystem>
#include <vector>
#include <cstring>
#include <csignal>
#include <algorithm>

#include <unistd.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <fcntl.h>
#include <poll.h>

namespace fs = std::filesystem;

// ═══════════════════════════════════════════════
//                 COULEURS ANSI
// ═══════════════════════════════════════════════

#define C_RESET   "\033[0m"
#define C_RED     "\033[31m"
#define C_GREEN   "\033[32m"
#define C_YELLOW  "\033[33m"
#define C_BLUE    "\033[34m"
#define C_MAGENTA "\033[35m"
#define C_CYAN    "\033[36m"
#define C_BOLD    "\033[1m"
#define C_DIM     "\033[2m"

// ═══════════════════════════════════════════════
//              STRUCTURE DE RÉSULTAT
// ═══════════════════════════════════════════════

struct TestResult {
    std::string testName;
    bool        passed;
    std::string stdout_output;
    std::string stderr_output;
    std::string expected;
    int         exitCode;
    int         signal;       // 0 = pas de signal, sinon SIGSEGV, SIGABRT, etc.
    bool        timeout;
    std::string details;      // message d'explication supplémentaire
};

// ═══════════════════════════════════════════════
//             UTILITAIRES
// ═══════════════════════════════════════════════

// Remplacer les séquences littérales \n par de vrais retours à la ligne
static std::string unescapeNewlines(const std::string& s) {
    std::string result;
    result.reserve(s.size());
    for (size_t i = 0; i < s.size(); ++i) {
        if (i + 1 < s.size() && s[i] == '\\' && s[i + 1] == 'n') {
            result += '\n';
            ++i;
        } else {
            result += s[i];
        }
    }
    return result;
}

// Rendre les caractères invisibles visibles pour le debug
static std::string escapeForDisplay(const std::string& s) {
    std::string result;
    for (char c : s) {
        if (c == '\n') result += "\\n";
        else if (c == '\r') result += "\\r";
        else if (c == '\t') result += "\\t";
        else result += c;
    }
    return result;
}

// ═══════════════════════════════════════════════
//             CLASSE NODETESTER PRO
// ═══════════════════════════════════════════════

class NodeTesterPro {
public:
    // Timeout en secondes pour chaque test (anti boucle infinie)
    static constexpr int TIMEOUT_SEC = 5;

    // ─── Vérifier que le fichier JS existe ───
    static TestResult checkFileExists(const std::string& filePath) {
        TestResult res;
        res.testName = "Existence du fichier";
        res.expected = filePath;
        res.exitCode = 0;
        res.signal = 0;
        res.timeout = false;

        if (fs::exists(filePath)) {
            res.passed = true;
            res.details = "Le fichier existe.";
        } else {
            res.passed = false;
            res.details = "Le fichier '" + filePath + "' est introuvable !";
        }
        return res;
    }

    // ─── Vérifier que module.exports est présent ───
    static TestResult checkModuleExports(const std::string& filePath, const std::string& functionName) {
        TestResult res;
        res.testName = "module.exports";
        res.expected = "module.exports contient '" + functionName + "'";
        res.exitCode = 0;
        res.signal = 0;
        res.timeout = false;

        std::ifstream file(filePath);
        if (!file.is_open()) {
            res.passed = false;
            res.details = "Impossible d'ouvrir le fichier.";
            return res;
        }

        std::string content((std::istreambuf_iterator<char>(file)),
                             std::istreambuf_iterator<char>());
        file.close();

        // Chercher module.exports ou exports
        if (content.find("module.exports") != std::string::npos ||
            content.find("exports.") != std::string::npos) {
            // Chercher le nom de la fonction dans les exports
            if (content.find(functionName) != std::string::npos) {
                res.passed = true;
                res.details = "module.exports contient bien '" + functionName + "'.";
            } else {
                res.passed = false;
                res.details = "module.exports existe mais ne contient pas '" + functionName + "'.";
            }
        } else {
            res.passed = false;
            res.details = "Aucun module.exports trouvé dans le fichier ! "
                          "La fonction ne peut pas être importée par le tester.";
        }
        return res;
    }

    // ─── Créer le wrapper script (mode classique) ───
    static void createWrapperScript(const std::string& wrapperName,
                                    const std::string& targetJs,
                                    const std::string& functionCall,
                                    const std::string& mockDir = "") {
        std::ofstream file(wrapperName);
        std::size_t parenPos = functionCall.find('(');
        std::string funcName = functionCall.substr(0, parenPos);
        std::string args = (parenPos != std::string::npos) ? functionCall.substr(parenPos) : "()";

        // Si le chemin est absolu, pas besoin de prefixer avec ./
        std::string requirePath = targetJs;
        if (!targetJs.empty() && targetJs[0] != '/') {
            requirePath = "./" + targetJs;
        }
        file << "// Auto-generated wrapper (tester_pro v2.0)\n";
        if (!mockDir.empty()) {
            std::string absMockIndex = fs::absolute(mockDir + "/node_modules/readline-sync/index.js").string();
            file << "const Module = require('module');\n";
            file << "const origResolve = Module._resolveFilename;\n";
            file << "Module._resolveFilename = function(request, parent, isMain, options) {\n";
            file << "  if (request === 'readline-sync') {\n";
            file << "    return '" << absMockIndex << "';\n";
            file << "  }\n";
            file << "  return origResolve.call(this, request, parent, isMain, options);\n";
            file << "};\n";
        }
        file << "const imported = require('" << requirePath << "');\n";
        file << "const fn = (typeof imported === 'function') ? imported : (imported['" << funcName << "'] || imported.default);\n";
        file << "if (typeof fn === 'function') {\n";
        file << "    fn" << args << ";\n";
        file << "}\n";
        file.close();
    }

    // ─── Créer un mock readline-sync pour simuler l'input ───
    // readline-sync lit depuis /dev/tty, pas depuis stdin.
    // On crée un faux module dans /tmp qui retourne les réponses pré-configurées.
    static std::string createReadlineMock(const std::string& targetDir,
                                          const std::string& stdinInput) {
        std::string mockDir = "/tmp/__mock_readline_sync__";
        if (fs::exists(mockDir)) {
            fs::remove_all(mockDir);
        }
        fs::create_directories(mockDir + "/node_modules/readline-sync");

        // Parser les inputs (séparés par \n)
        std::string unescaped = unescapeNewlines(stdinInput);
        std::vector<std::string> inputs;
        std::istringstream iss(unescaped);
        std::string line;
        while (std::getline(iss, line)) {
            inputs.push_back(line);
        }

        // Créer le mock readline-sync/index.js
        std::string mockFile = mockDir + "/node_modules/readline-sync/index.js";
        std::ofstream mock(mockFile);
        mock << "// Auto-generated mock for readline-sync (tester_pro v2.0)\n";
        mock << "const _inputs = [";
        for (size_t i = 0; i < inputs.size(); ++i) {
            // Échapper les guillemets et backslashes dans l'input
            std::string escaped;
            for (char c : inputs[i]) {
                if (c == '\"' || c == '\\') escaped += '\\';
                escaped += c;
            }
            mock << "\"" << escaped << "\"";
            if (i + 1 < inputs.size()) mock << ", ";
        }
        mock << "];\n";
        mock << "let _idx = 0;\n";
        mock << "module.exports = {\n";
        mock << "  question: function(prompt) {\n";
        mock << "    if (prompt) process.stdout.write(prompt);\n";
        mock << "    if (_idx < _inputs.length) return _inputs[_idx++];\n";
        mock << "    return '';\n";
        mock << "  },\n";
        mock << "  questionInt: function(prompt) {\n";
        mock << "    return parseInt(this.question(prompt));\n";
        mock << "  },\n";
        mock << "  questionFloat: function(prompt) {\n";
        mock << "    return parseFloat(this.question(prompt));\n";
        mock << "  },\n";
        mock << "  keyInYN: function(prompt) {\n";
        mock << "    const ans = this.question(prompt);\n";
        mock << "    return ans.toLowerCase() === 'y';\n";
        mock << "  },\n";
        mock << "  keyInSelect: function(items, prompt) {\n";
        mock << "    return parseInt(this.question(prompt));\n";
        mock << "  }\n";
        mock << "};\n";
        mock.close();

        // Créer un package.json minimal pour le mock
        std::string pkgFile = mockDir + "/node_modules/readline-sync/package.json";
        std::ofstream pkg(pkgFile);
        pkg << "{\"name\":\"readline-sync\",\"version\":\"1.0.0\",\"main\":\"index.js\"}\n";
        pkg.close();

        return mockDir;
    }

    // ─── Nettoyer le mock readline-sync ───
    static void cleanupReadlineMock(const std::string& targetDir) {
        std::string mockDir = "/tmp/__mock_readline_sync__";
        if (fs::exists(mockDir)) {
            fs::remove_all(mockDir);
        }
    }

    // ─── Créer un wrapper pour le mode direct + stdin ───
    // Le wrapper intercepte require('readline-sync') et retourne le mock
    static void createDirectStdinWrapper(const std::string& wrapperName,
                                         const std::string& targetJs,
                                         const std::string& mockDir) {
        std::ofstream file(wrapperName);
        std::string absTarget = fs::absolute(targetJs).string();
        std::string absMockIndex = fs::absolute(mockDir + "/node_modules/readline-sync/index.js").string();
        file << "// Auto-generated wrapper (tester_pro v2.0)\n";
        file << "const Module = require('module');\n";
        file << "const origResolve = Module._resolveFilename;\n";
        file << "Module._resolveFilename = function(request, parent, isMain, options) {\n";
        file << "  if (request === 'readline-sync') {\n";
        file << "    return '" << absMockIndex << "';\n";
        file << "  }\n";
        file << "  return origResolve.call(this, request, parent, isMain, options);\n";
        file << "};\n";
        file << "require('" << absTarget << "');\n";
        file.close();
    }

    // ─── Exécuter un test ───
    static TestResult runFullTest(const std::string& jsFilePath,
                                  const std::string& expectedOutput) {
        TestResult res;
        res.testName = "Sortie du programme";
        res.expected = expectedOutput;
        res.exitCode = 0;
        res.signal = 0;
        res.timeout = false;

        // Créer pipe pour stdout
        int stdout_pipe[2];
        if (pipe(stdout_pipe) == -1) {
            res.passed = false;
            res.details = "Erreur système : pipe stdout.";
            return res;
        }

        // Créer pipe pour stderr
        int stderr_pipe[2];
        if (pipe(stderr_pipe) == -1) {
            close(stdout_pipe[0]);
            close(stdout_pipe[1]);
            res.passed = false;
            res.details = "Erreur système : pipe stderr.";
            return res;
        }

        pid_t pid = fork();
        if (pid == -1) {
            res.passed = false;
            res.details = "Erreur système : fork.";
            return res;
        }

        if (pid == 0) {
            // ═══ PROCESSUS ENFANT ═══
            // Rediriger stdout
            dup2(stdout_pipe[1], STDOUT_FILENO);
            // Rediriger stderr
            dup2(stderr_pipe[1], STDERR_FILENO);

            close(stdout_pipe[0]);
            close(stdout_pipe[1]);
            close(stderr_pipe[0]);
            close(stderr_pipe[1]);

            execlp("node", "node", jsFilePath.c_str(), nullptr);
            // Si execlp échoue
            perror("execlp");
            _exit(127);
        }

        // ═══ PROCESSUS PARENT ═══
        close(stdout_pipe[1]);
        close(stderr_pipe[1]);

        // Mettre les pipes en non-bloquant pour le timeout
        fcntl(stdout_pipe[0], F_SETFL, O_NONBLOCK);
        fcntl(stderr_pipe[0], F_SETFL, O_NONBLOCK);

        std::string stdout_data;
        std::string stderr_data;
        char buffer[256];
        bool child_done = false;
        int elapsed = 0;

        // Boucle de lecture avec timeout
        while (!child_done && elapsed < TIMEOUT_SEC * 10) {
            // Vérifier si l'enfant est terminé
            int status;
            pid_t result = waitpid(pid, &status, WNOHANG);

            if (result > 0) {
                child_done = true;
                // Analyser le statut
                if (WIFEXITED(status)) {
                    res.exitCode = WEXITSTATUS(status);
                } else if (WIFSIGNALED(status)) {
                    res.signal = WTERMSIG(status);
                }
            }

            // Lire stdout
            ssize_t n;
            while ((n = read(stdout_pipe[0], buffer, sizeof(buffer) - 1)) > 0) {
                buffer[n] = '\0';
                stdout_data += buffer;
            }

            // Lire stderr
            while ((n = read(stderr_pipe[0], buffer, sizeof(buffer) - 1)) > 0) {
                buffer[n] = '\0';
                stderr_data += buffer;
            }

            if (!child_done) {
                usleep(100000); // 100ms
                elapsed++;
            }
        }

        // Si timeout : tuer le processus
        if (!child_done) {
            kill(pid, SIGKILL);
            waitpid(pid, nullptr, 0);
            res.timeout = true;
        }

        // Lire les dernières données restantes dans les pipes
        ssize_t n;
        while ((n = read(stdout_pipe[0], buffer, sizeof(buffer) - 1)) > 0) {
            buffer[n] = '\0';
            stdout_data += buffer;
        }
        while ((n = read(stderr_pipe[0], buffer, sizeof(buffer) - 1)) > 0) {
            buffer[n] = '\0';
            stderr_data += buffer;
        }

        close(stdout_pipe[0]);
        close(stderr_pipe[0]);

        // Nettoyer la sortie (enlever \n final)
        if (!stdout_data.empty() && stdout_data.back() == '\n')
            stdout_data.pop_back();
        if (!stderr_data.empty() && stderr_data.back() == '\n')
            stderr_data.pop_back();

        res.stdout_output = stdout_data;
        res.stderr_output = stderr_data;

        // ─── VERDICT ───
        if (res.timeout) {
            res.passed = false;
            res.details = "TIMEOUT ! Le programme a dépassé " +
                          std::to_string(TIMEOUT_SEC) + "s. Boucle infinie probable.";
        } else if (res.signal != 0) {
            res.passed = false;
            res.details = "CRASH ! Le programme a reçu le signal " +
                          std::string(strsignal(res.signal)) +
                          " (signal " + std::to_string(res.signal) + ").";
        } else if (res.exitCode != 0 && stdout_data.empty()) {
            res.passed = false;
            res.details = "Le programme a quitté avec le code " +
                          std::to_string(res.exitCode) + " (erreur).";
        } else if (stdout_data == expectedOutput) {
            res.passed = true;
            res.details = "La sortie correspond parfaitement.";
        } else {
            res.passed = false;
            res.details = "La sortie ne correspond pas à l'attendu.";
        }

        return res;
    }
};

// ═══════════════════════════════════════════════
//              AFFICHAGE DES RÉSULTATS
// ═══════════════════════════════════════════════

void printSeparator() {
    std::cout << C_DIM << "  ────────────────────────────────────────────" << C_RESET << "\n";
}

void printResult(const TestResult& r, int index) {
    std::string status = r.passed
        ? (std::string(C_GREEN) + "✓ PASS" + C_RESET)
        : (std::string(C_RED)   + "✗ FAIL" + C_RESET);

    std::cout << "  " << C_BOLD << "Test " << index << C_RESET
              << " │ " << status
              << " │ " << C_CYAN << r.testName << C_RESET << "\n";

    if (!r.passed) {
        std::cout << C_DIM << "         └─ " << C_RESET << r.details << "\n";

        if (!r.expected.empty() && r.testName == "Sortie du programme") {
            std::cout << C_GREEN << "         Attendu : " << C_RESET
                      << "\"" << escapeForDisplay(r.expected) << "\"\n";
            std::cout << C_RED   << "         Reçu    : " << C_RESET
                      << "\"" << escapeForDisplay(r.stdout_output) << "\"\n";
        }

        if (!r.stderr_output.empty()) {
            std::cout << C_YELLOW << "         Stderr  : " << C_RESET << "\n";
            // Afficher les premières lignes de stderr (pas tout pour pas spammer)
            std::istringstream stream(r.stderr_output);
            std::string line;
            int lineCount = 0;
            while (std::getline(stream, line) && lineCount < 5) {
                std::cout << C_DIM << "           │ " << C_RESET << line << "\n";
                lineCount++;
            }
            if (lineCount == 5) {
                std::cout << C_DIM << "           │ ... (tronqué)" << C_RESET << "\n";
            }
        }

        if (r.timeout) {
            std::cout << C_MAGENTA << "         ⏱ Timeout après "
                      << NodeTesterPro::TIMEOUT_SEC << "s" << C_RESET << "\n";
        }

        if (r.signal != 0) {
            std::cout << C_RED << C_BOLD << "         💥 Signal : "
                      << strsignal(r.signal) << " (" << r.signal << ")" << C_RESET << "\n";
        }
    }
}

void printSummary(const std::vector<TestResult>& results) {
    int passed = 0, failed = 0;
    for (const auto& r : results) {
        if (r.passed) passed++;
        else failed++;
    }
    int total = passed + failed;

    std::cout << "\n";
    std::cout << C_BOLD << "  ╔══════════════════════════════════════╗\n";
    std::cout << "  ║           RÉSUMÉ DES TESTS           ║\n";
    std::cout << "  ╠══════════════════════════════════════╣\n";

    std::cout << "  ║  Total  : " << total << "                          ";
    // Ajustement padding (simple)
    std::cout << "║\n";

    std::cout << "  ║  " << C_GREEN << "Passés" << C_RESET << C_BOLD << " : " << passed;
    std::cout << "                          ║\n";

    std::cout << "  ║  " << C_RED << "Échoué" << C_RESET << C_BOLD << " : " << failed;
    std::cout << "                          ║\n";

    std::cout << "  ╠══════════════════════════════════════╣\n";

    if (failed == 0) {
        std::cout << "  ║  " << C_GREEN << "★  TOUS LES TESTS SONT PASSÉS  ★" << C_RESET << C_BOLD << "    ║\n";
    } else {
        std::cout << "  ║  " << C_RED << "✗  CERTAINS TESTS ONT ÉCHOUÉ   ✗" << C_RESET << C_BOLD << "    ║\n";
    }

    std::cout << "  ╚══════════════════════════════════════╝" << C_RESET << "\n\n";
}

// ═══════════════════════════════════════════════
//                  USAGE / HELP
// ═══════════════════════════════════════════════

void printUsage(const char* progName) {
    std::cerr << C_BOLD << C_BLUE
              << "\n  ╔══════════════════════════════════════════╗\n"
              << "  ║       🔧 MOULINETTE PRO v2.0 🔧          ║\n"
              << "  ╚══════════════════════════════════════════╝\n"
              << C_RESET << "\n";

    std::cerr << C_BOLD << "  MODE 1 — Wrapper (avec module.exports) :\n" << C_RESET;
    std::cerr << C_DIM << "    " << progName
              << " <ex_file> <wrapper> <func_call> <expected>\n\n" << C_RESET;
    std::cerr << "    Exemple :\n";
    std::cerr << C_CYAN << "    " << progName
              << " ex00/ft_hello_garden.js test.js"
              << " \"ft_hello_garden()\" \"Hello , Garden Community !\"\n\n" << C_RESET;

    std::cerr << C_BOLD << "  MODE 2 — Direct (exécute le fichier tel quel) :\n" << C_RESET;
    std::cerr << C_DIM << "    " << progName
              << " --direct <ex_file> <expected>\n\n" << C_RESET;
    std::cerr << "    Exemple :\n";
    std::cerr << C_CYAN << "    " << progName
              << " --direct ex00/ft_hello_garden.js \"Hello , Garden Community !\"\n\n" << C_RESET;

    std::cerr << C_BOLD << "  MODE 3 — Direct + Stdin (pour readline-sync) :\n" << C_RESET;
    std::cerr << C_DIM << "    " << progName
              << " --direct --stdin \"input\" <ex_file> <expected>\n\n" << C_RESET;
    std::cerr << "    Exemple :\n";
    std::cerr << C_CYAN << "    " << progName
              << " --direct --stdin \"Roses\" ex01/ft_garden_name.js"
              << " \"Garden : Roses\\nStatus : Growing well !\"\n\n" << C_RESET;

    std::cerr << C_DIM << "  Options :\n";
    std::cerr << "    --direct     Exécute le fichier JS directement (pas de wrapper)\n";
    std::cerr << "    --stdin \"x\"  Envoie \"x\" sur stdin du programme (simule l'input)\n";
    std::cerr << "    \\n           Dans <expected>, \\n = retour à la ligne\n";
    std::cerr << C_RESET << "\n";
}

// ═══════════════════════════════════════════════
//                     MAIN
// ═══════════════════════════════════════════════

int main(int argc, char *argv[]) {
    // ── Parser les arguments ──
    bool directMode = false;
    std::string stdinInput;
    std::vector<std::string> positionalArgs;

    for (int i = 1; i < argc; ++i) {
        std::string arg = argv[i];
        if (arg == "--direct") {
            directMode = true;
        } else if (arg == "--stdin") {
            if (i + 1 >= argc) {
                std::cerr << C_RED << "Erreur: " << C_RESET
                          << "--stdin nécessite un argument (l'input à envoyer).\n";
                return 1;
            }
            stdinInput = argv[++i];
        } else if (arg == "--help" || arg == "-h") {
            printUsage(argv[0]);
            return 0;
        } else {
            positionalArgs.push_back(arg);
        }
    }

    // ── Valider les arguments selon le mode ──
    if (directMode) {
        // Mode direct : <ex_file> <expected>
        if (positionalArgs.size() != 2) {
            std::cerr << C_RED << "Erreur: " << C_RESET
                      << "Mode --direct nécessite 2 arguments : <ex_file> <expected>\n\n";
            printUsage(argv[0]);
            return 1;
        }
    } else {
        // Mode wrapper : <ex_file> <wrapper> <func_call> <expected>
        if (positionalArgs.size() != 4) {
            std::cerr << C_RED << "Erreur: " << C_RESET
                      << "Mode wrapper nécessite 4 arguments.\n\n";
            printUsage(argv[0]);
            return 1;
        }
        if (!stdinInput.empty()) {
            // Stdin aussi supporté en mode wrapper
        }
    }

    std::string ex_file, wrapper, func_call, expected;

    if (directMode) {
        ex_file  = positionalArgs[0];
        expected = unescapeNewlines(positionalArgs[1]);
    } else {
        ex_file   = positionalArgs[0];
        wrapper   = positionalArgs[1];
        func_call = positionalArgs[2];
        expected  = unescapeNewlines(positionalArgs[3]);
    }

    // Extraire le nom de la fonction (mode wrapper seulement)
    std::string funcName;
    if (!directMode) {
        funcName = func_call.substr(0, func_call.find('('));
    }

    // ── Affichage header ──
    std::cout << "\n";
    std::cout << C_BOLD << C_BLUE
              << "  ╔══════════════════════════════════════════╗\n"
              << "  ║     🔧 MOULINETTE PRO v2.0 - TESTER 🔧   ║\n"
              << "  ╚══════════════════════════════════════════╝"
              << C_RESET << "\n\n";

    std::cout << C_DIM << "  Fichier  : " << C_RESET << ex_file << "\n";
    std::cout << C_DIM << "  Mode     : " << C_RESET
              << (directMode ? "Direct (exécution directe)" : "Wrapper (module.exports)") << "\n";
    if (!directMode) {
        std::cout << C_DIM << "  Fonction : " << C_RESET << func_call << "\n";
    }
    if (!stdinInput.empty()) {
        std::cout << C_DIM << "  Stdin    : " << C_RESET << "\"" << stdinInput << "\"\n";
    }
    std::cout << C_DIM << "  Attendu  : " << C_RESET << "\"" << escapeForDisplay(expected) << "\"\n";
    std::cout << C_DIM << "  Timeout  : " << C_RESET << NodeTesterPro::TIMEOUT_SEC << "s\n";
    std::cout << "\n";
    printSeparator();

    std::vector<TestResult> results;

    // ── TEST 1 : Existence du fichier ──
    TestResult t1 = NodeTesterPro::checkFileExists(ex_file);
    results.push_back(t1);
    printResult(t1, 1);
    printSeparator();

    if (!t1.passed) {
        printSummary(results);
        return 1;
    }

    if (directMode) {
        // ═══ MODE DIRECT ═══

        if (!stdinInput.empty()) {
            // ── Mode direct + stdin : utiliser le mock readline-sync ──
            std::string targetDir = fs::path(ex_file).parent_path().string();
            if (targetDir.empty()) targetDir = ".";

            std::string mockDir = NodeTesterPro::createReadlineMock(targetDir, stdinInput);
            std::string stdinWrapper = "__stdin_wrapper__.js";
            NodeTesterPro::createDirectStdinWrapper(stdinWrapper, ex_file, mockDir);

            // ── TEST 2 : Exécution avec mock stdin ──
            TestResult t2 = NodeTesterPro::runFullTest(stdinWrapper, expected);
            results.push_back(t2);
            printResult(t2, 2);
            printSeparator();

            // Nettoyage
            fs::remove(stdinWrapper);
            NodeTesterPro::cleanupReadlineMock(targetDir);
        } else {
            // ── TEST 2 : Exécution directe simple ──
            TestResult t2 = NodeTesterPro::runFullTest(ex_file, expected);
            results.push_back(t2);
            printResult(t2, 2);
            printSeparator();
        }

    } else {
        // ═══ MODE WRAPPER (classique) ═══

        // ── TEST 2 : Vérification de module.exports ──
        TestResult t2 = NodeTesterPro::checkModuleExports(ex_file, funcName);
        results.push_back(t2);
        printResult(t2, 2);
        printSeparator();

        if (!t2.passed) {
            printSummary(results);
            return 1;
        }

        // ── TEST 3 : Exécution et vérification de la sortie ──
        std::string targetDir = fs::path(ex_file).parent_path().string();
        if (targetDir.empty()) targetDir = ".";

        std::string mockDir;
        if (!stdinInput.empty()) {
            mockDir = NodeTesterPro::createReadlineMock(targetDir, stdinInput);
        }

        NodeTesterPro::createWrapperScript(wrapper, ex_file, func_call, mockDir);

        TestResult t3 = NodeTesterPro::runFullTest(wrapper, expected);
        results.push_back(t3);
        printResult(t3, 3);
        printSeparator();

        // Nettoyage
        fs::remove(wrapper);
        if (!mockDir.empty()) {
            NodeTesterPro::cleanupReadlineMock(targetDir);
        }
    }

    // ── Résumé final ──
    printSummary(results);

    // Return code : 0 si tout passe, 1 sinon
    for (const auto& r : results) {
        if (!r.passed) return 1;
    }
    return 0;
}
