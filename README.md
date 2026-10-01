Set-ExecutionPolicy -Scope Process Bypass
.\install.ps1

# 🚀 Configuração Automática do Neovim + LazyVim + Nerd Fonts (Windows)

Scripts automatizados para instalação e configuração completa do **Neovim**, **LazyVim**, compilador C (**MinGW**) e **Nerd Fonts** no Windows 10/11 **sem necessidade de privilégios de administrador (Non-Admin)**.

---

## 📦 O que este projeto faz?

1. **Instalação em espaço de usuário (via Scoop)**:
   - **Neovim** (versão mais recente estável)
   - **ripgrep** (`rg`) para buscas instantâneas
   - **fd** (`fd`) para busca rápida de arquivos
   - **lazygit** para controle de versão interativo via terminal
   - **fzf** para fuzzy finding
   - **tree-sitter** CLI
   - **MinGW (GCC 16 / Make)** para que o `nvim-treesitter` compile nativamente os parsers de código no Windows.
2. **Fontes para Programadores com Ligaduras e Emojis/Ícones**:
   - Baixa e instala **JetBrains Mono Nerd Font** e **Fira Code Nerd Font** na pasta de fontes do usuário (`%LOCALAPPDATA%\Microsoft\Windows\Fonts`).
   - Registra as fontes no Registro do Windows (`HKCU`) e notifica o sistema via API Win32 sem reiniciar a máquina.
3. **Instalação e Ajuste do LazyVim**:
   - Clona o starter oficial do LazyVim em `%LOCALAPPDATA%\nvim`.
   - Adiciona configuração nativa e otimizada de UTF-8 para o PowerShell no Neovim.
   - Sincroniza e pré-instala todos os plugins essenciais em modo headless.
4. **Integração com Terminais e Editores**:
   - Configura o **Windows Terminal** para usar a `JetBrainsMono Nerd Font`.
   - Configura o **VS Code** com fontes, ligaduras ativadas e integração com o backend do Neovim instalado.

---

## ⚡ Como executar em uma máquina nova (1 clique)

Abra o **PowerShell** (não precisa ser como Administrador) e execute:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\install.ps1
```

Ou execute direto em uma linha:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
```

---

## 📁 Estrutura dos Scripts

| Arquivo | Descrição |
| :--- | :--- |
| `install.ps1` | **Script Mestre**. Executa todo o processo em sequência e valida a saúde do ambiente. |
| `01-install-tools.ps1` | Instala o Scoop, Neovim, ripgrep, fd, lazygit, fzf, tree-sitter e MinGW. |
| `02-install-fonts.ps1` | Baixa e registra JetBrains Mono e Fira Code Nerd Fonts no usuário. |
| `03-setup-lazyvim.ps1` | Clona o LazyVim starter e inicializa os plugins. |
| `04-configure-terminals.ps1` | Configura o Windows Terminal e o VS Code (`settings.json`). |

---

## ⚙️ Configuração do Shell (PowerShell UTF-8 no Neovim)

Para que os comandos do terminal integrado (`:terminal`) e subprocessos do Neovim no Windows funcionem sem problemas de acentuação e encoding, o arquivo `lua/config/options.lua` do Neovim inclui:

```lua
-- Windows PowerShell configuration for Neovim terminal and shell commands
if vim.fn.has("win32") == 1 then
  local shell = vim.fn.executable("pwsh") == 1 and "pwsh" or "powershell"
  vim.o.shell = shell
  vim.o.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command "
    .. "[Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
  vim.o.shellredir = "2>&1 | Out-File -Encoding utf8 %s; exit $LastExitCode"
  vim.o.shellpipe = "2>&1 | Out-File -Encoding utf8 %s; exit $LastExitCode"
  vim.o.shellquote = ""
  vim.o.shellxquote = ""
end
```

---

## ⌨️ Atalhos Principais do LazyVim

- `<Space>`: Tecla Líder (`<leader>`).
- `<Space>ff`: Encontrar arquivos (find files).
- `<Space>sg`: Busca global de texto (grep via ripgrep).
- `<Space>e`: Alternar o explorador de arquivos na barra lateral.
- `<Space>gg`: Abrir o LazyGit.
- `<Space>l`: Gerenciador de plugins (Lazy).
- `:checkhealth`: Diagnóstico completo do Neovim e plugins.

---

## 📤 Como versionar e subir para o GitHub

No diretório deste repositório (`C:\Users\emerson\scripts-nvim`), execute:

```powershell
git init
git add .
git commit -m "feat: scripts de instalacao automatica neovim, lazyvim e nerd fonts (non-admin)"
git branch -M main
git remote add origin https://github.com/SEU_USUARIO/SEU_REPOSITORIO.git
git push -u origin main
```
