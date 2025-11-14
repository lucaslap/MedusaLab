#!/bin/bash

#########################################
# Script de Verificação de Serviços
# Uso: ./verificar_servicos.sh <IP_ALVO>
# Autor: Lucas
# Data: 2025-11-13
#########################################

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Verificar argumentos
if [ -z "$1" ]; then
    echo -e "${RED}[ERRO]${NC} Por favor, forneça o IP do alvo"
    echo "Uso: $0 <IP_ALVO>"
    exit 1
fi

TARGET=$1
REPORT_FILE="scan_report_$(date +%Y%m%d_%H%M%S).txt"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Verificação de Serviços Vulneráveis${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${YELLOW}[*]${NC} Alvo: $TARGET"
echo -e "${YELLOW}[*]${NC} Data: $(date)"
echo ""

# Verificar se o nmap está instalado
if ! command -v nmap &> /dev/null; then
    echo -e "${RED}[ERRO]${NC} Nmap não está instalado!"
    echo "Execute: sudo apt install nmap -y"
    exit 1
fi

# Iniciar relatório
{
    echo "=========================================="
    echo "  Relatório de Verificação de Serviços"
    echo "=========================================="
    echo "Alvo: $TARGET"
    echo "Data: $(date)"
    echo "=========================================="
    echo ""
} > "$REPORT_FILE"

# 1. Verificar conectividade
echo -e "${YELLOW}[*]${NC} Etapa 1/5: Verificando conectividade..."
if ping -c 3 -W 2 "$TARGET" &> /dev/null; then
    echo -e "${GREEN}[+]${NC} Alvo está acessível"
    echo "[+] Alvo acessível" >> "$REPORT_FILE"
else
    echo -e "${RED}[ERRO]${NC} Alvo não está acessível"
    echo "[ERRO] Alvo não está acessível" >> "$REPORT_FILE"
    exit 1
fi

# 2. Scan rápido de portas comuns
echo -e "${YELLOW}[*]${NC} Etapa 2/5: Escaneando portas comuns..."
COMMON_PORTS="21,22,23,25,80,110,139,143,443,445,3306,3389,5900,8080"
nmap -p "$COMMON_PORTS" --open -T4 "$TARGET" -oN - | tee -a "$REPORT_FILE"

# 3. Identificar serviços com versões
echo ""
echo -e "${YELLOW}[*]${NC} Etapa 3/5: Identificando versões dos serviços..."
nmap -sV -p "$COMMON_PORTS" "$TARGET" -oN - | tee -a "$REPORT_FILE"

# 4. Verificar serviços específicos vulneráveis
echo ""
echo -e "${YELLOW}[*]${NC} Etapa 4/5: Verificando serviços específicos..."

# FTP
echo -e "${BLUE}[*]${NC} Verificando FTP (porta 21)..."
if timeout 5 bash -c "echo > /dev/tcp/$TARGET/21" 2>/dev/null; then
    echo -e "${GREEN}[+]${NC} FTP detectado - Vulnerável a força bruta"
    echo "[+] FTP (21) - ABERTO - Testável com Medusa" >> "$REPORT_FILE"
else
    echo -e "${YELLOW}[-]${NC} FTP não detectado"
    echo "[-] FTP (21) - FECHADO" >> "$REPORT_FILE"
fi

# SSH
echo -e "${BLUE}[*]${NC} Verificando SSH (porta 22)..."
if timeout 5 bash -c "echo > /dev/tcp/$TARGET/22" 2>/dev/null; then
    echo -e "${GREEN}[+]${NC} SSH detectado - Vulnerável a força bruta"
    echo "[+] SSH (22) - ABERTO - Testável com Medusa" >> "$REPORT_FILE"
else
    echo -e "${YELLOW}[-]${NC} SSH não detectado"
    echo "[-] SSH (22) - FECHADO" >> "$REPORT_FILE"
fi

# HTTP
echo -e "${BLUE}[*]${NC} Verificando HTTP (porta 80)..."
if timeout 5 bash -c "echo > /dev/tcp/$TARGET/80" 2>/dev/null; then
    echo -e "${GREEN}[+]${NC} HTTP detectado - Verificar formulários web"
    echo "[+] HTTP (80) - ABERTO - Verificar DVWA/formulários" >> "$REPORT_FILE"
    
    if command -v curl &> /dev/null; then
        echo -e "${BLUE}[*]${NC} Tentando identificar aplicações web..."
        
        # Verificar DVWA
        if curl -s "http://$TARGET/dvwa/" | grep -q "DVWA"; then
            echo -e "${GREEN}[+]${NC} DVWA detectado!"
            echo "[+] DVWA detectado em /dvwa/" >> "$REPORT_FILE"
        fi
        
        # Verificar phpMyAdmin
        if curl -s "http://$TARGET/phpmyadmin/" | grep -q "phpMyAdmin"; then
            echo -e "${GREEN}[+]${NC} phpMyAdmin detectado!"
            echo "[+] phpMyAdmin detectado em /phpmyadmin/" >> "$REPORT_FILE"
        fi
    fi
else
    echo -e "${YELLOW}[-]${NC} HTTP não detectado"
    echo "[-] HTTP (80) - FECHADO" >> "$REPORT_FILE"
fi

# SMB
echo -e "${BLUE}[*]${NC} Verificando SMB (portas 139/445)..."
SMB_FOUND=false

if timeout 5 bash -c "echo > /dev/tcp/$TARGET/445" 2>/dev/null; then
    echo -e "${GREEN}[+]${NC} SMB (445) detectado - Vulnerável a força bruta"
    echo "[+] SMB (445) - ABERTO - Testável com Medusa" >> "$REPORT_FILE"
    SMB_FOUND=true
fi

if timeout 5 bash -c "echo > /dev/tcp/$TARGET/139" 2>/dev/null; then
    echo -e "${GREEN}[+]${NC} NetBIOS (139) detectado"
    echo "[+] NetBIOS (139) - ABERTO" >> "$REPORT_FILE"
    SMB_FOUND=true
fi

if [ "$SMB_FOUND" = false ]; then
    echo -e "${YELLOW}[-]${NC} SMB não detectado"
    echo "[-] SMB - FECHADO" >> "$REPORT_FILE"
fi

# 5. Resumo e recomendações
echo ""
echo -e "${YELLOW}[*]${NC} Etapa 5/5: Gerando resumo..."
echo ""
{
    echo ""
    echo "=========================================="
    echo "  RESUMO E RECOMENDAÇÕES"
    echo "=========================================="
    echo ""
    echo "Serviços testáveis com Medusa:"
} >> "$REPORT_FILE"

# Listar módulos do Medusa disponíveis
if command -v medusa &> /dev/null; then
    echo ""
    echo -e "${GREEN}[+]${NC} Módulos do Medusa disponíveis para os serviços encontrados:"
    echo ""
    echo "Módulos disponíveis:" >> "$REPORT_FILE"
    
    # Listar alguns módulos relevantes
    for module in ftp ssh http web-form smbnt mysql postgres; do
        if medusa -d 2>/dev/null | grep -q "$module"; then
            echo -e "  ${GREEN}✓${NC} $module"
            echo "  - $module" >> "$REPORT_FILE"
        fi
    done
fi

{
    echo ""
    echo "Comandos sugeridos para testes:"
    echo ""
    echo "# Ataque FTP:"
    echo "medusa -h $TARGET -U wordlists/usuarios.txt -P wordlists/senhas_ftp.txt -M ftp -t 4"
    echo ""
    echo "# Ataque SSH:"
    echo "medusa -h $TARGET -U wordlists/usuarios.txt -P wordlists/senhas_comuns.txt -M ssh -t 4"
    echo ""
    echo "# Ataque SMB:"
    echo "medusa -h $TARGET -U wordlists/usuarios.txt -P wordlists/senhas_comuns.txt -M smbnt -t 1"
    echo ""
    echo "=========================================="
} >> "$REPORT_FILE"

# Exibir resumo
echo ""
echo -e "${GREEN}[+]${NC} Verificação concluída!"
echo -e "${YELLOW}[*]${NC} Relatório salvo em: $REPORT_FILE"
echo ""

# Mostrar estatísticas
OPEN_PORTS=$(grep -c "ABERTO" "$REPORT_FILE" 2>/dev/null || echo "0")
echo -e "${BLUE}[*]${NC} Estatísticas:"
echo -e "  ${GREEN}•${NC} Portas abertas: $OPEN_PORTS"
echo -e "  ${GREEN}•${NC} Relatório completo: $REPORT_FILE"

echo ""
echo -e "${YELLOW}[*]${NC} Próximos passos:"
echo -e "  1. Revisar o relatório: cat $REPORT_FILE"
echo -e "  2. Executar testes de força bruta nos serviços encontrados"
echo -e "  3. Documentar os resultados"
echo ""
