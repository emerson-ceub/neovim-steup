<#
.SYNOPSIS
    Script Mestre de Instalacao e Configuracao do Neovim + LazyVim + Nerd Fonts para Windows (Sem Administrador).
.DESCRIPTION
    Executa todos os passos necessarios para preparar um ambiente de desenvolvimento completo:
    1. Instala o Scoop no usuario e baixa Neovim, ripgrep, fd, lazygit, fzf, tree-sitter e MinGW (GCC/Make).
    2. Instala JetBrains Mono Nerd Font e Fira Code Nerd Font no usuario e registra no Windows.
    3. Clona o LazyVim starter e configura o PowerShell UTF-8 no options.lua.
    4. Configura as fontes e integracoes no Windows Terminal e no VS Code.
    5. Executa a verificacao final de saude do LazyVim (:checkhealth).
.USAGE
    powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
#>

$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Clear-Host
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "   INSTALADOR NEOVIM + LAZYVIM + NERD FONTS (NON-ADMIN)   " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "Diretorio base: $scriptDir" -ForegroundColor Gray

# Passo 1: Ferramentas CLI
& (Join-Path $scriptDir "01-install-tools.ps1")

# Passo 2: Fontes Nerd Font
& (Join-Path $scriptDir "02-install-fonts.ps1")

# Passo 3: LazyVim
& (Join-Path $scriptDir "03-setup-lazyvim.ps1")

# Passo 4: Terminais e VS Code
& (Join-Path $scriptDir "04-configure-terminals.ps1")

# Verificacao Final
Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host "                VERIFICACAO DE SAUDE FINAL                 " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green

$scoopDir = Join-Path $env:USERPROFILE "scoop"
$env:PATH = "$scoopDir\shims;$scoopDir\apps\mingw\current\bin;$env:PATH"

Write-Host "`n[+] Executando Neovim checkhealth (lazyvim)..." -ForegroundColor Yellow
& "$scoopDir\shims\nvim.exe" --headless "+checkhealth lazyvim" "+w! $env:TEMP\checkhealth_summary.txt" +qa
if (Test-Path "$env:TEMP\checkhealth_summary.txt") {
    Get-Content "$env:TEMP\checkhealth_summary.txt" | Where-Object { $_ -match 'OK|WARNING|ERROR' }
    Remove-Item "$env:TEMP\checkhealth_summary.txt" -Force -ErrorAction SilentlyContinue
}

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host "  TUDO PRONTO! O Neovim e o LazyVim estao instalados!     " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "Para iniciar, abra uma nova janela do terminal e digite:" -ForegroundColor Yellow
Write-Host "  nvim`n" -ForegroundColor Cyan
