# 📤 Como Publicar no GitHub

Guia passo a passo para criar e publicar seu repositório no GitHub.

---

## 📋 Pré-requisitos

1. **Conta no GitHub**: [Criar conta](https://github.com/signup)
2. **Git instalado**: Verificar com `git --version`
   - Windows: [Download Git](https://git-scm.com/download/win)
   - Linux: `sudo apt install git -y`

---

## 🚀 Passo a Passo

### 1️⃣ Configurar Git (Primeira vez)

```bash
# Configurar nome
git config --global user.name "Seu Nome"

# Configurar email
git config --global user.email "seu.email@example.com"

# Verificar configurações
git config --list
```

### 2️⃣ Inicializar Repositório Local

```bash
# Navegar até a pasta do projeto
cd "c:\Users\Lucas\Desktop\Nova pasta\desafio-seguranca-medusa"

# Inicializar repositório Git
git init

# Verificar status
git status
```

### 3️⃣ Adicionar Arquivos ao Repositório

```bash
# Adicionar todos os arquivos
git add .

# Ou adicionar arquivos específicos
git add README.md
git add wordlists/
git add scripts/
git add docs/

# Verificar o que será commitado
git status
```

### 4️⃣ Fazer o Primeiro Commit

```bash
# Criar commit com mensagem
git commit -m "Initial commit: Projeto de segurança com Medusa e Kali Linux"

# Verificar histórico
git log
```

### 5️⃣ Criar Repositório no GitHub

**Opção A: Via Website**

1. Acesse [github.com](https://github.com)
2. Clique no botão **+** (canto superior direito) → **New repository**
3. Preencha:
   - **Repository name**: `desafio-seguranca-medusa`
   - **Description**: "Projeto de testes de penetração com Kali Linux e Medusa - Desafio DIO"
   - **Visibilidade**: ✅ Public
   - **NÃO** marque "Initialize with README" (já temos)
4. Clique em **Create repository**

**Opção B: Via GitHub CLI (gh)**

```bash
# Instalar GitHub CLI (se não tiver)
# https://cli.github.com/

# Autenticar
gh auth login

# Criar repositório
gh repo create desafio-seguranca-medusa --public --source=. --remote=origin
```

### 6️⃣ Conectar Repositório Local ao GitHub

```bash
# Adicionar remote (substitua SEU-USUARIO pelo seu username)
git remote add origin https://github.com/SEU-USUARIO/desafio-seguranca-medusa.git

# Verificar remote
git remote -v

# Renomear branch para main (se necessário)
git branch -M main
```

### 7️⃣ Enviar Código para o GitHub

```bash
# Push inicial
git push -u origin main

# Será solicitado login do GitHub
# Use seu username e Personal Access Token (não a senha)
```

**⚠️ Autenticação**:

Desde 2021, GitHub requer **Personal Access Token** em vez de senha:

1. Acesse: [github.com/settings/tokens](https://github.com/settings/tokens)
2. Clique em **Generate new token (classic)**
3. Selecione escopos: `repo`, `workflow`
4. Copie o token gerado
5. Use como senha quando fazer push

### 8️⃣ Verificar Upload

1. Acesse: `https://github.com/SEU-USUARIO/desafio-seguranca-medusa`
2. Verifique se todos os arquivos estão lá
3. Confirme que o README.md está sendo exibido

---

## 🔄 Atualizações Futuras

Quando fizer alterações no projeto:

```bash
# 1. Verificar mudanças
git status

# 2. Adicionar arquivos modificados
git add .
# ou específicos:
git add README.md
git add scripts/novo_script.sh

# 3. Commit com mensagem descritiva
git commit -m "Adiciona novo cenário de ataque para MySQL"

# 4. Enviar para o GitHub
git push origin main
```

---

## 📸 Adicionar Imagens ao Repositório

```bash
# 1. Adicionar imagens à pasta
cp screenshot.png images/ataques/

# 2. Adicionar ao git
git add images/ataques/screenshot.png

# 3. Commit
git commit -m "Adiciona evidência de ataque FTP"

# 4. Push
git push origin main
```

**Referenciar no README**:

```markdown
![Ataque FTP](images/ataques/screenshot.png)
```

---

## 🌟 Melhorar Visibilidade do Repositório

### Adicionar Topics

No GitHub:
1. Vá até seu repositório
2. Clique em ⚙️ (engrenagem) ao lado de "About"
3. Adicione topics:
   - `cybersecurity`
   - `pentesting`
   - `kali-linux`
   - `medusa`
   - `brute-force`
   - `ethical-hacking`
   - `dio-bootcamp`
   - `security-testing`

### Criar README Atrativo

Já incluído! O README tem:
- ✅ Badges
- ✅ Emojis
- ✅ Estrutura clara
- ✅ Exemplos de código
- ✅ Tabelas
- ✅ Avisos legais

### Adicionar GitHub Actions (Opcional)

Criar `.github/workflows/lint.yml`:

```yaml
name: Markdown Lint

on: [push, pull_request]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Lint Markdown files
        uses: avto-dev/markdown-lint@v1
        with:
          args: '**/*.md'
```

---

## 📊 Estrutura Ideal do Repositório

```
desafio-seguranca-medusa/
├── README.md                 ⭐ Principal
├── QUICKSTART.md             🚀 Início rápido
├── LICENSE                   📜 Licença
├── .gitignore               🚫 Ignorar arquivos
│
├── docs/                     📚 Documentação
│   ├── configuracao_ambiente.md
│   ├── cenarios_ataque.md
│   └── mitigacao.md
│
├── wordlists/               📝 Listas de palavras
│   ├── usuarios.txt
│   ├── senhas_comuns.txt
│   └── senhas_ftp.txt
│
├── scripts/                 🔧 Scripts de automação
│   ├── ataque_ftp.sh
│   ├── ataque_smb.sh
│   └── verificar_servicos.sh
│
└── images/                  📸 Evidências
    ├── .gitkeep
    └── README.md
```

---

## 🎯 Checklist de Publicação

Antes de entregar o projeto:

- [ ] README.md completo e bem formatado
- [ ] Todos os scripts testados e funcionando
- [ ] Documentação técnica nas pastas `docs/`
- [ ] Wordlists incluídas
- [ ] .gitignore configurado
- [ ] Licença MIT incluída
- [ ] Aviso legal presente
- [ ] Capturas de tela (opcional, mas recomendado)
- [ ] Código comentado
- [ ] Sem informações sensíveis (IPs reais, senhas, etc.)
- [ ] Repository topics configurados
- [ ] Link testado e funcionando

---

## 📝 Template de Mensagem para Entrega (DIO)

**Título do Projeto**:
```
Desafio de Segurança Cibernética - Medusa & Kali Linux
```

**Descrição**:
```
Este projeto implementa e documenta testes de penetração usando Kali Linux e a ferramenta Medusa para simular ataques de força bruta em ambientes vulneráveis controlados (Metasploitable 2 e DVWA).

🎯 Objetivos alcançados:
✅ Configuração de ambiente isolado com VMs
✅ Execução de ataques em FTP, SSH, SMB e Web
✅ Documentação completa com comandos e resultados
✅ Proposição de medidas de mitigação
✅ Scripts de automação para facilitar testes
✅ Guias detalhados de boas práticas de segurança

📚 Estrutura do repositório:
- README.md principal com visão geral
- Documentação técnica em /docs
- Scripts de automação em /scripts
- Wordlists personalizadas
- Guias de configuração passo a passo

🛡️ Destaques:
- Implementação de 3+ cenários de ataque
- Guia completo de mitigação e hardening
- Scripts bash para automatizar testes
- Documentação técnica detalhada

⚠️ Observação: Projeto realizado em ambiente controlado e isolado, seguindo práticas éticas de segurança da informação.
```

**Link do Repositório**:
```
https://github.com/SEU-USUARIO/desafio-seguranca-medusa
```

---

## 🔗 Recursos Adicionais

### Markdown
- [GitHub Markdown Guide](https://guides.github.com/features/mastering-markdown/)
- [Emoji Cheat Sheet](https://github.com/ikatyang/emoji-cheat-sheet)

### Git
- [Git Cheat Sheet](https://education.github.com/git-cheat-sheet-education.pdf)
- [Pro Git Book](https://git-scm.com/book/pt-br/v2)

### GitHub
- [GitHub Docs](https://docs.github.com)
- [GitHub Learning Lab](https://lab.github.com/)

---

## 💡 Dicas Finais

1. **Commits Frequentes**: Faça commits pequenos e descritivos
2. **README Atrativo**: Use emojis, badges e formatação
3. **Documentação Clara**: Explique como reproduzir seus testes
4. **Código Limpo**: Comente scripts e mantenha organização
5. **Ética**: Sempre inclua avisos legais sobre uso responsável
6. **Portfólio**: Use este projeto para demonstrar suas habilidades
7. **Aprendizado**: Documente o que aprendeu, não apenas o que fez

---

**🎉 Parabéns!** Seu projeto está pronto para ser compartilhado!

Se tiver dúvidas, consulte a [documentação do GitHub](https://docs.github.com) ou a comunidade DIO.
