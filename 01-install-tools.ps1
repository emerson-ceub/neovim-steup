<#
.SYNOPSIS
    Instala o Scoop e as ferramentas essenciais para Neovim e LazyVim sem privilégios de Administrador.
#>

$ErrorActionPreference = 'Stop'

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  1. Instalando Scoop e Ferramentas CLI  " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# 1. Instalação do Scoop
$scoopDir = Join-Path $env:USERPROFILE "scoop"
$scoopCmd = Join-Path $scoopDir "shims\scoop.cmd"
$scoopPs1 = Join-Path $scoopDir "shims\scoop.ps1"

if (-not (Test-Path $scoopPs1)) {
    Write-Host "`n[+] Instalando Scoop no espaco de usuario ($scoopDir)..." -ForegroundColor Yellow
    $ProgressPreference = 'SilentlyContinue'
    $installScript = Join-Path $env:TEMP "install-scoop.ps1"
    Invoke-RestMethod -Uri "https://get.scoop.sh" -OutFile $installScript
    & powershell -NoProfile -ExecutionPolicy Bypass -File $installScript -RunAsAdmin:0
    Remove-Item $installScript -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "`n[OK] Scoop ja instalado em $scoopDir" -ForegroundColor Green
}

# Atualizar PATH na sessao atual
$env:PATH = "$scoopDir\shims;$scoopDir\apps\mingw\current\bin;$env:PATH"

# 2. Adicionar bucket extras para lazygit
Write-Host "`n[+] Configurando buckets do Scoop..." -ForegroundColor Yellow
& $scoopPs1 bucket add extras 2>$null

# 3. Lista de pacotes necessarios
$packages = @(
    "git",          # Sistema de controle de versao (necessario para LazyVim e plugins)
    "neovim",       # Editor principal
    "ripgrep",      # Busca de texto ultra-rapida (telescope / fzf-lua)
    "fd",           # Busca de arquivos ultra-rapida
    "lazygit",      # Interface de git interativa no terminal
    "fzf",          # Fuzzy finder
    "tree-sitter",  # CLI do Tree-sitter para parsers de sintaxe
    "mingw"         # Compilador C (GCC/Make) para o nvim-treesitter compilar parsers
)

Write-Host "`n[+] Instalando pacotes via Scoop..." -ForegroundColor Yellow
foreach ($pkg in $packages) {
    $isInstalled = Test-Path (Join-Path $scoopDir "apps\$pkg")
    if ($isInstalled) {
        Write-Host "  [OK] $pkg ja instalado." -ForegroundColor Green
    } else {
        Write-Host "  [->] Instalando $pkg..." -ForegroundColor Cyan
        & $scoopPs1 install $pkg
    }
}

Write-Host "`n[+] Verificando ferramentas instaladas:" -ForegroundColor Cyan
& "$scoopDir\shims\nvim.exe" --version | Select-Object -First 1
& "$scoopDir\shims\rg.exe" --version | Select-Object -First 1
& "$scoopDir\shims\fd.exe" --version | Select-Object -First 1
& "$scoopDir\shims\lazygit.exe" --version | Select-Object -First 1
if (Test-Path "$scoopDir\apps\mingw\current\bin\gcc.exe") {
    & "$scoopDir\apps\mingw\current\bin\gcc.exe" --version | Select-Object -First 1
}

Write-Host "`n[OK] Ferramentas CLI prontas com sucesso!" -ForegroundColor Green
