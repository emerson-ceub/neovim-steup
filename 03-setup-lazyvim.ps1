<#
.SYNOPSIS
    Configura o LazyVim starter no perfil de usuário e realiza o bootstrap inicial dos plugins.
#>

$ErrorActionPreference = 'Stop'

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  3. Configurando LazyVim Starter        " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

$nvimConfigDir = Join-Path $env:LOCALAPPDATA "nvim"
$scoopDir = Join-Path $env:USERPROFILE "scoop"
$env:PATH = "$scoopDir\shims;$scoopDir\apps\mingw\current\bin;$env:PATH"

# 1. Clonar LazyVim starter se não existir
if (-not (Test-Path (Join-Path $nvimConfigDir "init.lua"))) {
    Write-Host "`n[+] Clonando o repositório starter do LazyVim em $nvimConfigDir..." -ForegroundColor Yellow
    git clone https://github.com/LazyVim/starter $nvimConfigDir
    
    # Remover o .git do starter conforme instrução oficial
    $gitFolder = Join-Path $nvimConfigDir ".git"
    if (Test-Path $gitFolder) {
        Remove-Item -Path $gitFolder -Recurse -Force
    }
} else {
    Write-Host "`n[OK] Configuracao do Neovim ja existe em $nvimConfigDir" -ForegroundColor Green
}

# 2. Configurar suporte a PowerShell no options.lua
$optionsFile = Join-Path $nvimConfigDir "lua\config\options.lua"
if (Test-Path $optionsFile) {
    $content = Get-Content $optionsFile -Raw
    if ($content -notmatch 'vim\.fn\.has\("win32"\)') {
        Write-Host "[+] Adicionando configuracao recomendada de PowerShell no options.lua..." -ForegroundColor Yellow
        $psConfig = @"

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
"@
        Add-Content -Path $optionsFile -Value $psConfig
    }
}

# 3. Executar o bootstrap headless para baixar plugins
Write-Host "`n[+] Executando o bootstrap do LazyVim (download de plugins)..." -ForegroundColor Yellow
& "$scoopDir\shims\nvim.exe" --headless "+Lazy! sync" +qa

Write-Host "`n[OK] LazyVim configurado e plugins sincronizados!" -ForegroundColor Green
