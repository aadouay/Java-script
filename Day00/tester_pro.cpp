/*
** ╔══════════════════════════════════════════════════════════════════╗
** ║                    TESTER PRO - Moulinette JS                    ║
** ║                                                                  ║
** ║  Tests effectués :                                               ║
** ║    ✓ Existence du fichier                                        ║
** ║    ✓ Vérification de module.exports                              ║
** ║    ✓ Comparaison de la sortie (stdout)                           ║
** ║    ✓ Détection de crash / segfault (signaux SIGSEGV, SIGABRT)    ║
** ║    ✓ Détection de timeout (boucle infinie)                       ║
** ║    ✓ Capture de stderr (erreurs de syntaxe, exceptions)          ║
** ║    ✓ Vérification du code de sortie (exit code)                  ║
** ║                                                                  ║
** ║  Usage :                                                         ║
** ║    ./tester_pro <ex_file> <wrapper> <func_call> <expected>       ║
** ║                                                                  ║
** ║  Exemple :                                                       ║
** ║    ./tester_pro ex01/ft_hello_garden.js ex01_test.js \            ║
** ║                "ft_hello_garden()" "Hello, Garden Community!"     ║
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

    // ─── Créer le wrapper script ───
    static void createWrapperScript(const std::string& wrapperName,
                                    const std::string& targetJs,
                                    const std::string& functionCall) {
        std::ofstream file(wrapperName);
        std::string funcName = functionCall.substr(0, functionCall.find('('));
        file << "const { " << funcName << " } = require('./" << targetJs << "');\n";
        file << functionCall << ";\n";
        file.close();
    }

    // ─── Exécuter le test principal (stdout, stderr, crash, timeout) ───
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
            std::cout << C_GREEN << "         Attendu : " << C_RESET << "\"" << r.expected << "\"\n";
            std::cout << C_RED   << "         Reçu    : " << C_RESET << "\"" << r.stdout_output << "\"\n";
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
//                     MAIN
// ═══════════════════════════════════════════════

/*
**  Usage :
**    ./tester_pro <ex_file> <wrapper_name> <function_call> <expected_output>
**
**  Exemple :
**    ./tester_pro ex01/ft_hello_garden.js ex01_test.js "ft_hello_garden()" "Hello, Garden Community!"
*/

int main(int argc, char *argv[]) {
    if (argc != 5) {
        std::cerr << C_RED << "Erreur: " << C_RESET << "Nombre d'arguments invalide.\n\n";
        std::cerr << C_BOLD << "Usage:" << C_RESET << "\n";
        std::cerr << "  " << argv[0] << " <ex_file> <wrapper_name> <function_call> <expected_output>\n\n";
        std::cerr << C_BOLD << "Exemple:" << C_RESET << "\n";
        std::cerr << "  " << argv[0]
                  << " ex01/ft_hello_garden.js ex01_test.js"
                  << " \"ft_hello_garden()\" \"Hello, Garden Community!\"\n\n";
        std::cerr << C_DIM << "  <ex_file>         : Chemin du fichier JS de l'étudiant\n";
        std::cerr << "  <wrapper_name>    : Nom du fichier wrapper temporaire\n";
        std::cerr << "  <function_call>   : Appel de fonction à tester (ex: \"maFonction(42)\")\n";
        std::cerr << "  <expected_output>  : Sortie attendue sur stdout" << C_RESET << "\n";
        return 1;
    }

    std::string ex_file   = argv[1];
    std::string wrapper   = argv[2];
    std::string func_call = argv[3];
    std::string expected  = argv[4];

    // Extraire le nom de la fonction (sans les parenthèses et arguments)
    std::string funcName = func_call.substr(0, func_call.find('('));

    std::cout << "\n";
    std::cout << C_BOLD << C_BLUE
              << "  ╔══════════════════════════════════════════╗\n"
              << "  ║       🔧 MOULINETTE PRO - TESTER 🔧      ║\n"
              << "  ╚══════════════════════════════════════════╝"
              << C_RESET << "\n\n";

    std::cout << C_DIM << "  Fichier  : " << C_RESET << ex_file << "\n";
    std::cout << C_DIM << "  Fonction : " << C_RESET << func_call << "\n";
    std::cout << C_DIM << "  Attendu  : " << C_RESET << "\"" << expected << "\"\n";
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
        // Si le fichier n'existe pas, pas besoin de continuer
        printSummary(results);
        return 1;
    }

    // ── TEST 2 : Vérification de module.exports ──
    TestResult t2 = NodeTesterPro::checkModuleExports(ex_file, funcName);
    results.push_back(t2);
    printResult(t2, 2);
    printSeparator();

    if (!t2.passed) {
        // Si pas de module.exports, on ne peut pas tester
        printSummary(results);
        return 1;
    }

    // ── TEST 3 : Exécution et vérification de la sortie ──
    // Créer le wrapper
    NodeTesterPro::createWrapperScript(wrapper, ex_file, func_call);

    TestResult t3 = NodeTesterPro::runFullTest(wrapper, expected);
    results.push_back(t3);
    printResult(t3, 3);
    printSeparator();

    // Nettoyage
    fs::remove(wrapper);

    // ── Résumé final ──
    printSummary(results);

    // Return code : 0 si tout passe, 1 sinon
    for (const auto& r : results) {
        if (!r.passed) return 1;
    }
    return 0;
}
