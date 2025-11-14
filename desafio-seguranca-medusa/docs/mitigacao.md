# 🛡️ Guia de Mitigação e Boas Práticas de Segurança

Este documento apresenta medidas práticas para prevenir ataques de força bruta e melhorar a postura de segurança dos seus sistemas.

---

## 📚 Índice

1. [Políticas de Senha Forte](#1-políticas-de-senha-forte)
2. [Bloqueio de Conta e Limitação de Taxa](#2-bloqueio-de-conta-e-limitação-de-taxa)
3. [Autenticação Multifator (MFA)](#3-autenticação-multifator-mfa)
4. [Monitoramento e Detecção](#4-monitoramento-e-detecção)
5. [Hardening de Serviços](#5-hardening-de-serviços)
6. [Segurança de Rede](#6-segurança-de-rede)
7. [Boas Práticas por Serviço](#7-boas-práticas-por-serviço)

---

## 1. Políticas de Senha Forte

### 📋 Requisitos Mínimos

```
✓ Comprimento mínimo: 12 caracteres (ideal: 16+)
✓ Complexidade:
  - Letras maiúsculas (A-Z)
  - Letras minúsculas (a-z)
  - Números (0-9)
  - Caracteres especiais (!@#$%^&*)
✓ Sem palavras de dicionário
✓ Sem informações pessoais (nome, data de nascimento)
✓ Sem sequências óbvias (123456, qwerty)
✓ Histórico: Não permitir reutilização das últimas 10 senhas
✓ Rotação: Trocar a cada 90 dias (ou menos)
```

### 🔧 Implementação no Linux (PAM)

```bash
# Editar /etc/pam.d/common-password
sudo nano /etc/pam.d/common-password

# Adicionar política de complexidade
password requisite pam_pwquality.so retry=3 minlen=12 dcredit=-1 ucredit=-1 ocredit=-1 lcredit=-1

# Parâmetros:
# minlen=12     : Comprimento mínimo de 12 caracteres
# dcredit=-1    : Ao menos 1 dígito
# ucredit=-1    : Ao menos 1 letra maiúscula
# lcredit=-1    : Ao menos 1 letra minúscula
# ocredit=-1    : Ao menos 1 caractere especial
# retry=3       : Permitir 3 tentativas de definir senha
```

### 🔧 Implementação no Windows (GPO)

```powershell
# Via PowerShell (requer privilégios de administrador)
secedit /export /cfg C:\secpol.cfg

# Editar C:\secpol.cfg e adicionar:
[System Access]
MinimumPasswordLength = 12
PasswordComplexity = 1
PasswordHistorySize = 10
MaximumPasswordAge = 90

# Aplicar
secedit /configure /db secedit.sdb /cfg C:\secpol.cfg
```

### 🎯 Geradores de Senha Recomendados

```bash
# OpenSSL (Linux)
openssl rand -base64 16

# pwgen (Linux)
sudo apt install pwgen
pwgen -s 16 1

# PowerShell (Windows)
-join ((33..126) | Get-Random -Count 16 | ForEach-Object {[char]$_})

# Ferramentas online:
# - 1Password
# - Bitwarden
# - LastPass
```

---

## 2. Bloqueio de Conta e Limitação de Taxa

### 🚫 Bloqueio Temporário de Conta

#### Linux - Fail2Ban

```bash
# Instalar Fail2Ban
sudo apt install fail2ban -y

# Criar arquivo de configuração local
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Editar configuração
sudo nano /etc/fail2ban/jail.local
```

**Configuração do Fail2Ban**:

```ini
[DEFAULT]
# Tempo de bloqueio (em segundos)
bantime = 3600

# Janela de tempo para contar falhas
findtime = 600

# Número máximo de tentativas
maxretry = 3

# Ação a tomar
banaction = iptables-multiport

# SSH Protection
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 1800

# FTP Protection
[vsftpd]
enabled = true
port = ftp
filter = vsftpd
logpath = /var/log/vsftpd.log
maxretry = 3

# Apache Protection
[apache-auth]
enabled = true
port = http,https
filter = apache-auth
logpath = /var/log/apache*/*error.log
maxretry = 5

# SMB Protection
[samba]
enabled = true
port = netbios-ssn,microsoft-ds
filter = samba
logpath = /var/log/samba/log.*
maxretry = 3
```

```bash
# Iniciar e habilitar Fail2Ban
sudo systemctl start fail2ban
sudo systemctl enable fail2ban

# Verificar status
sudo fail2ban-client status

# Ver IPs banidos
sudo fail2ban-client status sshd

# Desbanir um IP
sudo fail2ban-client set sshd unbanip 192.168.56.10
```

#### Linux - PAM (Manual)

```bash
# Editar /etc/pam.d/common-auth
sudo nano /etc/pam.d/common-auth

# Adicionar antes de pam_unix.so
auth required pam_tally2.so deny=3 unlock_time=1800 onerr=fail audit

# Parâmetros:
# deny=3           : Bloqueia após 3 tentativas falhas
# unlock_time=1800 : Desbloqueia após 30 minutos
# onerr=fail       : Bloqueia em caso de erro
# audit            : Registra eventos no log

# Ver tentativas falhas de um usuário
sudo pam_tally2 --user=username

# Resetar contador
sudo pam_tally2 --user=username --reset
```

#### Windows - Account Lockout Policy

```powershell
# Via GPO: Local Security Policy > Account Lockout Policy
# Ou via PowerShell:

net accounts /lockoutthreshold:3
net accounts /lockoutduration:30
net accounts /lockoutwindow:30

# Parâmetros:
# lockoutthreshold: Número de tentativas falhas (3)
# lockoutduration: Tempo de bloqueio em minutos (30)
# lockoutwindow: Janela de tempo para contar tentativas (30 min)
```

### ⏱️ Rate Limiting com iptables

```bash
# Limitar conexões SSH por IP
sudo iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --set
sudo iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 4 -j DROP

# Limitar conexões FTP
sudo iptables -A INPUT -p tcp --dport 21 -m state --state NEW -m recent --set --name FTP
sudo iptables -A INPUT -p tcp --dport 21 -m state --state NEW -m recent --update --seconds 60 --hitcount 3 --name FTP -j DROP

# Salvar regras
sudo iptables-save > /etc/iptables/rules.v4

# Ou usar netfilter-persistent
sudo apt install iptables-persistent
sudo netfilter-persistent save
```

### 🌐 Rate Limiting em Apache (Web)

```apache
# Instalar mod_evasive
sudo apt install libapache2-mod-evasive

# Configurar /etc/apache2/mods-available/evasive.conf
<IfModule mod_evasive20.c>
    DOSHashTableSize 3097
    DOSPageCount 5
    DOSSiteCount 50
    DOSPageInterval 1
    DOSSiteInterval 1
    DOSBlockingPeriod 60
    DOSEmailNotify admin@example.com
</IfModule>

# Habilitar módulo
sudo a2enmod evasive
sudo systemctl restart apache2
```

---

## 3. Autenticação Multifator (MFA)

### 🔐 SSH com Google Authenticator

```bash
# 1. Instalar Google Authenticator PAM
sudo apt install libpam-google-authenticator -y

# 2. Configurar para usuário
google-authenticator

# Responder:
# - Time-based tokens? Yes
# - Update .google_authenticator? Yes
# - Disallow multiple uses? Yes
# - Increase time window? No
# - Enable rate-limiting? Yes

# 3. Editar /etc/pam.d/sshd
sudo nano /etc/pam.d/sshd

# Adicionar no topo:
auth required pam_google_authenticator.so

# 4. Editar /etc/ssh/sshd_config
sudo nano /etc/ssh/sshd_config

# Modificar:
ChallengeResponseAuthentication yes
UsePAM yes

# Adicionar:
AuthenticationMethods publickey,keyboard-interactive

# 5. Reiniciar SSH
sudo systemctl restart sshd
```

### 🔐 Web Application 2FA

Para aplicações web como DVWA, implementar:

- **Google Authenticator**: TOTP (Time-based One-Time Password)
- **SMS**: Código via mensagem de texto
- **Email**: Código via email
- **Hardware Keys**: YubiKey, Titan Security Key

**Exemplo PHP (básico)**:

```php
<?php
// Usar biblioteca como RobThree/TwoFactorAuth
require 'vendor/autoload.php';

use RobThree\Auth\TwoFactorAuth;

$tfa = new TwoFactorAuth('MyApp');

// Gerar segredo para usuário
$secret = $tfa->createSecret();

// Gerar QR Code
$qrCodeUrl = $tfa->getQRCodeImageAsDataUri('user@example.com', $secret);

// Verificar código
$code = $_POST['2fa_code'];
if ($tfa->verifyCode($secret, $code)) {
    // Código válido
    echo "Login successful!";
} else {
    echo "Invalid code!";
}
?>
```

---

## 4. Monitoramento e Detecção

### 📊 Logs Importantes

#### Linux

```bash
# Logs de autenticação
sudo tail -f /var/log/auth.log

# Logins SSH
sudo grep "Failed password" /var/log/auth.log

# Logins bem-sucedidos
sudo grep "Accepted password" /var/log/auth.log

# Últimos logins
last -a

# Tentativas falhas
sudo lastb

# Logs do FTP
sudo tail -f /var/log/vsftpd.log

# Logs do Apache
sudo tail -f /var/log/apache2/access.log
sudo tail -f /var/log/apache2/error.log
```

#### Windows

```powershell
# Eventos de login
Get-EventLog -LogName Security -InstanceId 4624 -Newest 10

# Tentativas de login falhas
Get-EventLog -LogName Security -InstanceId 4625 -Newest 10

# Bloqueios de conta
Get-EventLog -LogName Security -InstanceId 4740 -Newest 10
```

### 🔍 Monitoramento em Tempo Real

#### OSSEC (Host-based IDS)

```bash
# Instalar OSSEC
wget https://github.com/ossec/ossec-hids/archive/3.7.0.tar.gz
tar -zxvf 3.7.0.tar.gz
cd ossec-hids-3.7.0
sudo ./install.sh

# Configurar regras em /var/ossec/rules/local_rules.xml
<group name="authentication_failures,">
  <rule id="100001" level="10">
    <if_matched_sid>5503</if_matched_sid>
    <same_source_ip />
    <description>Multiple SSH authentication failures.</description>
  </rule>
</group>

# Iniciar OSSEC
sudo /var/ossec/bin/ossec-control start
```

#### Splunk / ELK Stack

Para ambientes corporativos, considere:

- **Splunk**: Plataforma comercial de SIEM
- **ELK Stack**: Elasticsearch + Logstash + Kibana (open source)
- **Graylog**: Alternativa open source

### 📧 Alertas Automáticos

```bash
# Script simples de alerta por email
sudo nano /usr/local/bin/ssh_alert.sh
```

```bash
#!/bin/bash
EMAIL="admin@example.com"
LOG="/var/log/auth.log"

# Monitorar tentativas falhas
tail -fn0 "$LOG" | while read line; do
    if echo "$line" | grep -q "Failed password"; then
        IP=$(echo "$line" | awk '{print $11}')
        echo "Failed SSH login from $IP" | mail -s "SSH Alert" "$EMAIL"
    fi
done
```

```bash
# Tornar executável
sudo chmod +x /usr/local/bin/ssh_alert.sh

# Executar como serviço (systemd)
sudo nano /etc/systemd/system/ssh-alert.service
```

---

## 5. Hardening de Serviços

### 🔒 SSH Hardening

```bash
# Editar /etc/ssh/sshd_config
sudo nano /etc/ssh/sshd_config
```

**Configurações Recomendadas**:

```bash
# Desabilitar login root
PermitRootLogin no

# Desabilitar autenticação por senha (usar apenas chaves)
PasswordAuthentication no

# Permitir apenas usuários específicos
AllowUsers user1 user2

# Mudar porta padrão (security by obscurity)
Port 2222

# Desabilitar login sem senha
PermitEmptyPasswords no

# Limitar tentativas de autenticação
MaxAuthTries 3

# Timeout de autenticação
LoginGraceTime 60

# Desabilitar X11 forwarding
X11Forwarding no

# Usar protocolo 2 apenas
Protocol 2

# Limitar conexões simultâneas
MaxStartups 3:50:10

# Banner de aviso legal
Banner /etc/ssh/banner.txt

# Reiniciar SSH
sudo systemctl restart sshd
```

### 🔒 FTP Hardening

```bash
# Editar /etc/vsftpd.conf
sudo nano /etc/vsftpd.conf
```

**Configurações Recomendadas**:

```bash
# Desabilitar login anônimo
anonymous_enable=NO

# Habilitar login local
local_enable=YES

# Permitir apenas upload
write_enable=YES

# Isolar usuários em chroot
chroot_local_user=YES

# Limitar taxa de transferência (KB/s)
local_max_rate=1024

# Limitar conexões por IP
max_per_ip=3

# Timeout de idle
idle_session_timeout=600

# Logging
xferlog_enable=YES
log_ftp_protocol=YES

# Banner
ftpd_banner=Acesso restrito - Autorização necessária

# Reiniciar vsftpd
sudo systemctl restart vsftpd
```

### 🔒 Apache Hardening

```apache
# Editar /etc/apache2/apache2.conf ou sites-enabled/default
sudo nano /etc/apache2/conf-available/security.conf
```

```apache
# Ocultar versão do servidor
ServerTokens Prod
ServerSignature Off

# Prevenir clickjacking
Header always set X-Frame-Options "SAMEORIGIN"

# XSS Protection
Header always set X-XSS-Protection "1; mode=block"

# Content Type Options
Header always set X-Content-Type-Options "nosniff"

# Limitar tamanho de requisição
LimitRequestBody 10485760

# Timeout
Timeout 60

# Desabilitar TRACE
TraceEnable Off

# Habilitar módulos de segurança
sudo a2enmod headers
sudo a2enmod security2
sudo systemctl restart apache2
```

### 🔒 SMB/Samba Hardening

```bash
# Editar /etc/samba/smb.conf
sudo nano /etc/samba/smb.conf
```

```ini
[global]
# Desabilitar SMBv1 (vulnerável)
min protocol = SMB2

# Limitar hosts
hosts allow = 192.168.56.0/24
hosts deny = ALL

# Habilitar log
log level = 2
log file = /var/log/samba/log.%m

# Limitar conexões
max connections = 5

# Desabilitar guest
map to guest = Never

# Senha criptografada
encrypt passwords = yes

# Reiniciar Samba
sudo systemctl restart smbd
```

---

## 6. Segurança de Rede

### 🛡️ Firewall (iptables)

```bash
# Script básico de firewall
sudo nano /etc/iptables/firewall.sh
```

```bash
#!/bin/bash

# Limpar regras existentes
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

# Política padrão: DROP
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Permitir loopback
iptables -A INPUT -i lo -j ACCEPT

# Permitir conexões estabelecidas
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Permitir SSH (porta 2222)
iptables -A INPUT -p tcp --dport 2222 -m state --state NEW -m recent --set
iptables -A INPUT -p tcp --dport 2222 -m state --state NEW -m recent --update --seconds 60 --hitcount 4 -j DROP
iptables -A INPUT -p tcp --dport 2222 -j ACCEPT

# Permitir HTTP/HTTPS
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Proteção contra Port Scan
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP

# Salvar regras
iptables-save > /etc/iptables/rules.v4

# Aplicar ao boot
echo "#!/bin/bash" > /etc/network/if-pre-up.d/firewall
echo "iptables-restore < /etc/iptables/rules.v4" >> /etc/network/if-pre-up.d/firewall
chmod +x /etc/network/if-pre-up.d/firewall
```

### 🔒 VPN para Acesso Remoto

```bash
# Instalar OpenVPN
sudo apt install openvpn easy-rsa -y

# Configurar CA e gerar certificados
make-cadir ~/openvpn-ca
cd ~/openvpn-ca
./easyrsa init-pki
./easyrsa build-ca
./easyrsa build-server-full server nopass
./easyrsa build-client-full client1 nopass

# Gerar chave DH
./easyrsa gen-dh

# Configurar servidor OpenVPN
sudo cp ~/openvpn-ca/pki/issued/server.crt /etc/openvpn/
sudo cp ~/openvpn-ca/pki/private/server.key /etc/openvpn/
sudo cp ~/openvpn-ca/pki/ca.crt /etc/openvpn/
sudo cp ~/openvpn-ca/pki/dh.pem /etc/openvpn/
```

---

## 7. Boas Práticas por Serviço

### SSH ✅

- ✓ Usar autenticação por chave pública
- ✓ Desabilitar login root
- ✓ Mudar porta padrão
- ✓ Implementar 2FA
- ✓ Limitar usuários permitidos
- ✓ Monitorar logs regularmente

### FTP ✅

- ✓ Preferir SFTP/SCP ao invés de FTP
- ✓ Se usar FTP, usar FTPS (FTP over SSL)
- ✓ Desabilitar login anônimo
- ✓ Usar chroot jail
- ✓ Limitar taxa de transferência

### Web ✅

- ✓ Implementar HTTPS (SSL/TLS)
- ✓ Usar CAPTCHA em formulários de login
- ✓ Implementar 2FA
- ✓ Rate limiting
- ✓ Validação de entrada
- ✓ WAF (Web Application Firewall)

### SMB ✅

- ✓ Desabilitar SMBv1
- ✓ Usar autenticação forte
- ✓ Limitar compartilhamentos
- ✓ Usar ACLs (Access Control Lists)
- ✓ Criptografar conexões

---

## 📊 Checklist de Segurança

```markdown
### Políticas de Acesso
- [ ] Senhas fortes (12+ caracteres)
- [ ] Rotação de senhas (90 dias)
- [ ] Sem credenciais padrão
- [ ] Histórico de senhas (10 últimas)

### Controles de Acesso
- [ ] Bloqueio de conta (3 tentativas)
- [ ] Rate limiting implementado
- [ ] Fail2Ban configurado
- [ ] Firewall ativo

### Autenticação
- [ ] 2FA em serviços críticos
- [ ] Autenticação por chave (SSH)
- [ ] Sessões expiram após inatividade

### Monitoramento
- [ ] Logs centralizados
- [ ] Alertas configurados
- [ ] Revisão periódica de logs
- [ ] IDS/IPS implementado

### Rede
- [ ] Segmentação de rede
- [ ] VPN para acesso remoto
- [ ] Portas desnecessárias fechadas
- [ ] Firewall configurado

### Serviços
- [ ] Versões atualizadas
- [ ] Configurações hardened
- [ ] Serviços desnecessários desabilitados
- [ ] Patches de segurança aplicados

### Backup e Recovery
- [ ] Backups regulares
- [ ] Teste de restore
- [ ] Plano de recuperação de desastres
```

---

## 🎓 Conclusão

Implementar essas medidas de mitigação é essencial para proteger seus sistemas contra ataques de força bruta e outras ameaças comuns. A segurança é um processo contínuo que requer:

1. **Vigilância Constante**: Monitorar logs e alertas
2. **Atualizações Regulares**: Manter sistemas e software atualizados
3. **Educação**: Treinar usuários em práticas seguras
4. **Testes**: Realizar auditorias e penetration tests regularmente
5. **Resposta a Incidentes**: Ter plano de ação para breaches

---

**Lembre-se**: A segurança é tão forte quanto seu elo mais fraco!
