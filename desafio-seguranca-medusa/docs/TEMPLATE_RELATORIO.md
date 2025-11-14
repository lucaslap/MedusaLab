# 📋 Relatório de Testes de Penetração

**Projeto**: Desafio de Segurança Cibernética - Medusa & Kali Linux  
**Data**: _[Inserir data]_  
**Executado por**: _[Seu nome]_  
**Versão**: 1.0

---

## 1. Sumário Executivo

### 1.1 Objetivos
Este relatório documenta os testes de penetração realizados em ambiente controlado utilizando Kali Linux e a ferramenta Medusa para identificar vulnerabilidades relacionadas a ataques de força bruta.

### 1.2 Escopo
- **Alvo**: Metasploitable 2 (192.168.56.20)
- **Serviços Testados**: FTP, SSH, SMB, HTTP
- **Período**: _[Data início]_ a _[Data fim]_
- **Metodologia**: OWASP Testing Guide

### 1.3 Resumo dos Resultados

| Severidade | Quantidade | Descrição |
|------------|-----------|-----------|
| 🔴 Crítica | _[X]_ | Credenciais padrão, acesso root |
| 🟠 Alta | _[X]_ | Sem limitação de taxa, sem bloqueio |
| 🟡 Média | _[X]_ | Serviços obsoletos |
| 🔵 Baixa | _[X]_ | Banners informativos |

---

## 2. Informações Técnicas

### 2.1 Ambiente de Teste

**Máquina Atacante (Kali Linux)**
- **Sistema Operacional**: Kali Linux 2023.x
- **IP**: 192.168.56.10
- **Ferramentas**: Medusa 2.2, Nmap 7.x, enum4linux

**Máquina Alvo (Metasploitable 2)**
- **Sistema Operacional**: Ubuntu 8.04 (Metasploitable 2)
- **IP**: 192.168.56.20
- **Serviços Ativos**: FTP (21), SSH (22), HTTP (80), SMB (139/445)

### 2.2 Metodologia

1. **Reconhecimento**: Descoberta de hosts e serviços
2. **Análise de Vulnerabilidades**: Identificação de configurações inseguras
3. **Exploração**: Execução de ataques de força bruta
4. **Validação**: Confirmação de acesso obtido
5. **Documentação**: Registro de evidências

---

## 3. Descobertas Detalhadas

### 3.1 Serviço FTP (Porta 21)

#### Descrição da Vulnerabilidade
O serviço FTP aceita credenciais fracas e não implementa mecanismos de proteção contra força bruta.

#### Evidências

**Comando Executado**:
```bash
medusa -h 192.168.56.20 -u msfadmin -P wordlists/senhas_ftp.txt -M ftp -v 4
```

**Resultado**:
```
ACCOUNT FOUND: [ftp] Host: 192.168.56.20 User: msfadmin Password: msfadmin [SUCCESS]
```

**Tempo para Descoberta**: ~3 minutos  
**Tentativas**: 18

#### Validação
```bash
ftp 192.168.56.20
# Login: msfadmin
# Password: msfadmin
# Status: SUCESSO - Acesso completo ao sistema
```

#### Severidade
🔴 **CRÍTICA**

#### Impacto
- Acesso completo ao sistema de arquivos
- Possibilidade de upload de arquivos maliciosos
- Vazamento de dados confidenciais

#### Recomendações
1. Alterar credencial padrão imediatamente
2. Implementar Fail2Ban para FTP
3. Considerar migração para SFTP
4. Implementar autenticação de dois fatores
5. Restringir acesso por IP com firewall

#### CVSS Score
**Base Score**: 9.8 (Critical)  
**Vector**: CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H

---

### 3.2 Serviço SSH (Porta 22)

#### Descrição da Vulnerabilidade
Serviço SSH aceita autenticação por senha e não possui proteção contra tentativas de força bruta.

#### Evidências

**Comando Executado**:
```bash
medusa -h 192.168.56.20 -U wordlists/usuarios.txt -P wordlists/senhas_comuns.txt -M ssh -t 4
```

**Resultado**:
```
ACCOUNT FOUND: [ssh] Host: 192.168.56.20 User: msfadmin Password: msfadmin [SUCCESS]
```

**Tempo para Descoberta**: ~5 minutos  
**Tentativas**: 45

#### Validação
```bash
ssh msfadmin@192.168.56.20
# Password: msfadmin
# Status: SUCESSO - Shell interativo obtido
```

#### Severidade
🔴 **CRÍTICA**

#### Impacto
- Acesso shell completo ao sistema
- Possibilidade de escalação de privilégios
- Execução de comandos arbitrários

#### Recomendações
1. Desabilitar autenticação por senha
2. Usar apenas autenticação por chave pública
3. Implementar Fail2Ban para SSH
4. Mudar porta padrão (22) para porta não-padrão
5. Implementar 2FA com Google Authenticator

---

### 3.3 Serviço SMB (Portas 139/445)

#### Descrição da Vulnerabilidade
Compartilhamentos SMB com credenciais fracas e sem política de bloqueio de conta.

#### Evidências

**Enumeração de Usuários**:
```bash
enum4linux -U 192.168.56.20
```

**Resultado**:
```
user:[msfadmin] rid:[0x3e8]
user:[service] rid:[0x3ee]
user:[user] rid:[0x3ec]
```

**Password Spraying**:
```bash
medusa -h 192.168.56.20 -U wordlists/usuarios.txt -p service -M smbnt -t 1
```

**Resultado**:
```
ACCOUNT FOUND: [smbnt] Host: 192.168.56.20 User: service Password: service [SUCCESS]
```

#### Validação
```bash
smbclient //192.168.56.20/tmp -U service%service
# Status: SUCESSO - Acesso ao compartilhamento
```

#### Severidade
🟠 **ALTA**

#### Impacto
- Acesso a compartilhamentos de rede
- Possível acesso a dados sensíveis
- Movimento lateral na rede

#### Recomendações
1. Implementar política de senha forte
2. Desabilitar SMBv1
3. Implementar bloqueio de conta após tentativas falhas
4. Restringir compartilhamentos ao mínimo necessário
5. Usar criptografia SMB

---

### 3.4 Aplicação Web - DVWA (Porta 80)

#### Descrição da Vulnerabilidade
Formulário de login sem proteção contra força bruta ou CAPTCHA.

#### Evidências

**URL**: http://192.168.56.20/dvwa/login.php

**Tentativa Manual**: Verificado que não há limitação de tentativas

**Ataque Automatizado** (usando Hydra como alternativa):
```bash
hydra -l admin -P wordlists/senhas_comuns.txt 192.168.56.20 http-post-form \
  "/dvwa/login.php:username=^USER^&password=^PASS^&Login=Login:F=Login failed"
```

**Resultado**:
```
[80][http-post-form] host: 192.168.56.20 login: admin password: password
```

#### Severidade
🟡 **MÉDIA**

#### Impacto
- Acesso não autorizado à aplicação
- Possível acesso a dados de usuários
- Exploração de outras vulnerabilidades web

#### Recomendações
1. Implementar CAPTCHA (reCAPTCHA v3)
2. Adicionar rate limiting (max 3 tentativas/minuto)
3. Implementar bloqueio temporário de conta
4. Adicionar autenticação de dois fatores
5. Usar HTTPS (TLS/SSL)

---

## 4. Análise de Risco

### 4.1 Matriz de Risco

| Vulnerabilidade | Probabilidade | Impacto | Risco |
|----------------|---------------|---------|-------|
| FTP - Credenciais Padrão | Alta | Crítico | 🔴 Crítico |
| SSH - Força Bruta | Alta | Crítico | 🔴 Crítico |
| SMB - Senhas Fracas | Média | Alto | 🟠 Alto |
| Web - Sem Rate Limit | Média | Médio | 🟡 Médio |

### 4.2 Vulnerabilidades por Categoria

**Credenciais e Autenticação**
- ✗ Credenciais padrão não alteradas
- ✗ Senhas fracas (< 8 caracteres)
- ✗ Sem política de complexidade de senha
- ✗ Sem autenticação multifator

**Controles de Acesso**
- ✗ Sem limitação de taxa de tentativas
- ✗ Sem bloqueio de conta após falhas
- ✗ Sem timeout de sessão
- ✗ Sem monitoramento de acessos

**Configuração de Serviços**
- ✗ Serviços com configuração padrão
- ✗ Versões obsoletas de software
- ✗ Banners informativos habilitados
- ✗ Serviços desnecessários ativos

---

## 5. Plano de Remediação

### 5.1 Ações Imediatas (Críticas)

| # | Ação | Serviço | Prazo | Responsável |
|---|------|---------|-------|-------------|
| 1 | Alterar todas as credenciais padrão | Todos | 24h | Admin |
| 2 | Implementar Fail2Ban | FTP, SSH, SMB | 48h | Admin |
| 3 | Desabilitar autenticação por senha SSH | SSH | 24h | Admin |
| 4 | Restringir acesso por firewall | Todos | 48h | Network |

### 5.2 Ações de Curto Prazo (1-2 semanas)

| # | Ação | Serviço | Prazo | Responsável |
|---|------|---------|-------|-------------|
| 5 | Implementar 2FA | SSH, Web | 1 sem | Admin |
| 6 | Migrar FTP para SFTP | FTP | 2 sem | Admin |
| 7 | Implementar CAPTCHA | Web | 1 sem | Dev |
| 8 | Atualizar versões de software | Todos | 1 sem | Admin |

### 5.3 Ações de Longo Prazo (1-3 meses)

| # | Ação | Prazo | Responsável |
|---|------|-------|-------------|
| 9 | Implementar SIEM (Splunk/ELK) | 2 meses | Security |
| 10 | Treinamento de segurança para equipe | 1 mês | HR |
| 11 | Auditoria de segurança regular | Contínuo | Security |
| 12 | Política de senhas corporativa | 1 mês | Security |

---

## 6. Evidências Técnicas

### 6.1 Logs de Ataque

**FTP - auth.log**:
```
Nov 13 10:23:45 target vsftpd: pam_unix(vsftpd:auth): authentication failure; logname= uid=0 euid=0 tty=ftp ruser=admin rhost=192.168.56.10
Nov 13 10:23:47 target vsftpd: pam_unix(vsftpd:auth): authentication failure; logname= uid=0 euid=0 tty=ftp ruser=admin rhost=192.168.56.10
Nov 13 10:23:50 target vsftpd: pam_unix(vsftpd:session): session opened for user msfadmin
```

### 6.2 Capturas de Tela

_[Adicionar screenshots em images/]_

1. Nmap scan results
2. Medusa FTP attack
3. Successful SSH login
4. SMB share access
5. DVWA login bypass

### 6.3 Arquivos de Resultado

- `resultados_ftp.txt` - Resultados completos do ataque FTP
- `resultados_ssh.txt` - Resultados completos do ataque SSH
- `resultados_smb.txt` - Resultados completos do ataque SMB
- `scan_report.txt` - Relatório do Nmap

---

## 7. Conclusões

### 7.1 Resumo

Este teste de penetração identificou **múltiplas vulnerabilidades críticas** relacionadas a:
- Credenciais fracas e padrão
- Falta de mecanismos de proteção contra força bruta
- Configurações inseguras de serviços
- Ausência de monitoramento e alertas

### 7.2 Principais Descobertas

1. **100% dos serviços testados** eram vulneráveis a ataques de força bruta
2. **Credenciais padrão** permitiram acesso imediato ao sistema
3. **Nenhum mecanismo de detecção** estava ativo durante os ataques
4. **Tempo médio de comprometimento**: 5 minutos

### 7.3 Recomendações Gerais

Para melhorar significativamente a postura de segurança:

✅ **Implementar autenticação forte**
- Senhas complexas (16+ caracteres)
- Autenticação multifator (2FA/MFA)
- Autenticação baseada em certificados

✅ **Adicionar controles de acesso**
- Rate limiting
- Bloqueio de conta temporário
- Whitelist de IPs

✅ **Monitoramento e detecção**
- SIEM centralizado
- Alertas em tempo real
- Análise de logs

✅ **Hardening de sistemas**
- Desabilitar serviços desnecessários
- Atualizar software regularmente
- Seguir benchmarks CIS

---

## 8. Referências

### 8.1 Ferramentas Utilizadas
- **Medusa** 2.2 - http://www.foofus.net/goons/jmk/medusa/
- **Nmap** 7.x - https://nmap.org/
- **enum4linux** - https://github.com/CiscoCXSecurity/enum4linux

### 8.2 Frameworks de Referência
- OWASP Testing Guide v4
- NIST SP 800-115 - Technical Guide to Information Security Testing
- PTES - Penetration Testing Execution Standard

### 8.3 Vulnerabilidades Relacionadas
- CWE-521: Weak Password Requirements
- CWE-307: Improper Restriction of Excessive Authentication Attempts
- CWE-798: Use of Hard-coded Credentials

---

## 9. Apêndices

### Apêndice A: Comandos Utilizados

```bash
# Reconhecimento
nmap -sV -sC -p- -oN scan_completo.txt 192.168.56.20
enum4linux -a 192.168.56.20

# Ataques
medusa -h 192.168.56.20 -U wordlists/usuarios.txt -P wordlists/senhas_ftp.txt -M ftp -t 4
medusa -h 192.168.56.20 -U wordlists/usuarios.txt -P wordlists/senhas_comuns.txt -M ssh -t 4
medusa -h 192.168.56.20 -U wordlists/usuarios.txt -p service -M smbnt -t 1

# Validação
ftp 192.168.56.20
ssh msfadmin@192.168.56.20
smbclient //192.168.56.20/tmp -U service%service
```

### Apêndice B: Wordlists Utilizadas

- **usuarios.txt**: 16 usuários comuns
- **senhas_comuns.txt**: 50 senhas mais usadas
- **senhas_ftp.txt**: 18 senhas específicas para FTP

### Apêndice C: Configurações Recomendadas

Ver arquivo `docs/mitigacao.md` para configurações detalhadas de hardening.

---

**Relatório elaborado por**: _[Seu nome]_  
**Data**: _[Data]_  
**Versão**: 1.0

---

**⚠️ CONFIDENCIAL**: Este relatório contém informações sensíveis sobre vulnerabilidades de segurança. Distribuição restrita.
