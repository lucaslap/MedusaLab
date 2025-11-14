# 🖥️ Configuração do Ambiente de Testes

Este documento descreve o passo a passo para configurar um ambiente seguro e isolado para realizar os testes de penetração.

## 📋 Requisitos do Sistema

### Hardware Mínimo
- **CPU**: Processador com suporte a virtualização (Intel VT-x ou AMD-V)
- **RAM**: 8GB (recomendado 16GB)
- **Disco**: 50GB de espaço livre
- **Rede**: Conexão com internet para downloads iniciais

### Software Necessário
- **VirtualBox** 6.0 ou superior ([Download](https://www.virtualbox.org/))
- **Kali Linux** (ISO ou OVA)
- **Metasploitable 2** (VM pré-configurada)

---

## 🚀 Passo 1: Instalação do VirtualBox

### Windows
1. Baixe o instalador do [site oficial](https://www.virtualbox.org/)
2. Execute o instalador e siga as instruções
3. Instale o Extension Pack para recursos adicionais

### Linux
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install virtualbox virtualbox-ext-pack -y

# Fedora/RHEL
sudo dnf install VirtualBox -y
```

### Verificar Instalação
```bash
VBoxManage --version
```

---

## 🔧 Passo 2: Configurar Rede Virtual

### Criar Rede Host-Only

1. Abra o VirtualBox
2. Vá em **Arquivo → Ferramentas → Gerenciador de Rede**
3. Clique em **Criar** para adicionar uma nova rede Host-Only
4. Configure:
   - **Nome**: vboxnet0
   - **IPv4**: 192.168.56.1
   - **Máscara**: 255.255.255.0
   - **DHCP**: Desabilitado (configuração manual nas VMs)

### Alternativa: Rede Interna

Para isolamento total sem acesso ao host:

1. Configure ambas as VMs para usar **Rede Interna**
2. Use o nome: `labnet`

---

## 🐧 Passo 3: Configurar Kali Linux

### Opção A: Download da VM Pré-configurada (Recomendado)

1. Baixe a VM do Kali: [Kali VM Downloads](https://www.kali.org/get-kali/#kali-virtual-machines)
2. Escolha a versão **VirtualBox 64-bit**
3. Extraia o arquivo `.7z`
4. Importe no VirtualBox:
   - Arquivo → Importar Appliance
   - Selecione o arquivo `.vbox` ou `.ova`

### Opção B: Instalação Manual

1. Baixe a ISO do Kali Linux
2. Crie uma nova VM no VirtualBox:
   - **Nome**: Kali-Lab
   - **Tipo**: Linux
   - **Versão**: Debian 64-bit
   - **RAM**: 2048 MB (mínimo)
   - **Disco**: 20 GB (dinâmico)
3. Monte a ISO e instale o sistema

### Configuração de Rede do Kali

1. Acesse as configurações da VM
2. **Adaptador 1**:
   - Habilitar placa de rede
   - Conectado a: **Placa em modo Host-Only**
   - Nome: vboxnet0
3. **Adaptador 2** (opcional, para internet):
   - Habilitar placa de rede
   - Conectado a: **NAT**

### Configurar IP Estático no Kali

```bash
# Editar configuração de rede
sudo nano /etc/network/interfaces

# Adicionar:
auto eth0
iface eth0 inet static
    address 192.168.56.10
    netmask 255.255.255.0
    gateway 192.168.56.1

# Reiniciar rede
sudo systemctl restart networking

# Verificar
ip addr show
```

### Credenciais Padrão
- **Usuário**: kali
- **Senha**: kali

---

## 🎯 Passo 4: Configurar Metasploitable 2

### Download

1. Baixe do site oficial: [Metasploitable 2](https://sourceforge.net/projects/metasploitable/)
2. Extraia o arquivo ZIP

### Importar no VirtualBox

1. Crie uma nova VM:
   - **Nome**: Metasploitable2
   - **Tipo**: Linux
   - **Versão**: Ubuntu 64-bit
   - **RAM**: 512 MB
   - **Disco**: Use o arquivo `.vmdk` extraído

2. Configuração de Rede:
   - **Adaptador 1**:
     - Habilitar placa de rede
     - Conectado a: **Placa em modo Host-Only**
     - Nome: vboxnet0

### Configurar IP Estático no Metasploitable

```bash
# Login (usuário: msfadmin, senha: msfadmin)

# Verificar IP atual
ifconfig

# Editar configuração
sudo nano /etc/network/interfaces

# Configurar IP estático
auto eth0
iface eth0 inet static
    address 192.168.56.20
    netmask 255.255.255.0
    gateway 192.168.56.1

# Reiniciar rede
sudo /etc/init.d/networking restart
```

### Credenciais Padrão
- **Usuário**: msfadmin
- **Senha**: msfadmin

---

## ✅ Passo 5: Verificar Conectividade

### No Kali Linux

```bash
# Verificar IP
ip addr show eth0

# Ping para o Metasploitable
ping -c 4 192.168.56.20

# Scan básico
nmap -sn 192.168.56.0/24

# Verificar serviços abertos no Metasploitable
nmap -sV -p- 192.168.56.20
```

### No Metasploitable

```bash
# Verificar IP
ifconfig

# Ping para o Kali
ping -c 4 192.168.56.10

# Verificar serviços rodando
sudo netstat -tulpn
```

---

## 🔨 Passo 6: Instalar Ferramentas no Kali

```bash
# Atualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar Medusa
sudo apt install medusa -y

# Verificar instalação
medusa -d

# Outras ferramentas úteis
sudo apt install nmap enum4linux smbclient hydra nikto -y

# Wordlists (já incluídas no Kali)
ls -la /usr/share/wordlists/
```

---

## 🌐 Passo 7: Acessar DVWA no Metasploitable

### No Navegador (Kali Linux)

1. Abra o Firefox
2. Acesse: `http://192.168.56.20/dvwa`
3. Login padrão:
   - **Usuário**: admin
   - **Senha**: password

### Configurar DVWA

1. Clique em **Setup / Reset DB**
2. Clique em **Create / Reset Database**
3. Faça login novamente
4. Vá em **DVWA Security** e configure para **Low**

---

## 📊 Resumo da Configuração

| VM | IP | Função | Credenciais |
|----|----|----|-------------|
| Kali Linux | 192.168.56.10 | Atacante | kali:kali |
| Metasploitable 2 | 192.168.56.20 | Alvo | msfadmin:msfadmin |

### Serviços Disponíveis no Metasploitable

- **FTP** (21): vsftpd 2.3.4
- **SSH** (22): OpenSSH 4.7p1
- **Telnet** (23): habilitado
- **HTTP** (80): Apache 2.2.8
- **SMB** (139/445): Samba 3.0.20
- **MySQL** (3306): MySQL 5.0.51a

---

## ⚠️ Boas Práticas de Segurança

1. **Isolamento**: Mantenha as VMs em rede isolada (Host-Only ou Interna)
2. **Snapshots**: Crie snapshots antes dos testes para restaurar facilmente
3. **Desligar**: Sempre desligue as VMs quando não estiver testando
4. **Backups**: Faça backup das configurações importantes
5. **Não expor**: Nunca conecte essas VMs diretamente à internet

---

## 🔄 Criar Snapshots

```bash
# No terminal do host
VBoxManage snapshot "Kali-Lab" take "Estado-Inicial" --description "Configuração limpa"
VBoxManage snapshot "Metasploitable2" take "Estado-Inicial" --description "Configuração limpa"

# Restaurar snapshot
VBoxManage snapshot "Kali-Lab" restore "Estado-Inicial"
```

---

## 🐛 Troubleshooting

### Problema: VMs não se comunicam

**Solução**:
```bash
# Verificar se estão na mesma rede
VBoxManage list hostonlyifs

# Verificar firewall no Kali
sudo ufw status
sudo ufw disable  # Temporariamente para testes

# Verificar iptables
sudo iptables -L
```

### Problema: Medusa não instala

**Solução**:
```bash
sudo apt update
sudo apt install -f
sudo dpkg --configure -a
sudo apt install medusa -y
```

### Problema: DVWA não carrega

**Solução**:
```bash
# No Metasploitable
sudo service apache2 restart
sudo service mysql restart

# Verificar logs
sudo tail -f /var/log/apache2/error.log
```

---

## 📚 Próximos Passos

Após configurar o ambiente:

1. ✅ Verificar conectividade entre as VMs
2. ✅ Acessar o DVWA
3. ✅ Executar scan básico com nmap
4. ✅ Testar login manual nos serviços
5. ✅ Prosseguir para os [Cenários de Ataque](cenarios_ataque.md)

---

**⚠️ Lembre-se**: Este ambiente é apenas para aprendizado. Nunca use essas técnicas em sistemas reais sem autorização!
