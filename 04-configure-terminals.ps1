<#
.SYNOPSIS
    Configura a fonte Nerd Font no Windows Terminal e no VS Code, e ajusta a integracao do Neovim no VS Code.
#>

$ErrorActionPreference = 'Continue'

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  4. Configurando Terminais e VS Code   " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# 1. Configurar Windows Terminal
$wtSettings = Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

if (Test-Path $wtSettings) {
    Write-Host "`n[+] Atualizando fonte no Windows Terminal..." -ForegroundColor Yellow
    try {
        $json = Get-Content $wtSettings -Raw | ConvertFrom-Json
        if (-not $json.profiles.defaults) {
            $json.profiles | Add-Member -MemberType NoteProperty -Name "defaults" -Value (New-Object PSObject) -Force
        }
        if (-not $json.profiles.defaults.font) {
            $json.profiles.defaults | Add-Member -MemberType NoteProperty -Name "font" -Value (New-Object PSObject) -Force
        }
        $json.profiles.defaults.font | Add-Member -MemberType NoteProperty -Name "face" -Value "JetBrainsMono Nerd Font" -Force

        $json | ConvertTo-Json -Depth 32 | Set-Content $wtSettings -Encoding UTF8
        Write-Host "  [OK] Windows Terminal configurado com JetBrainsMono Nerd Font!" -ForegroundColor Green
    } catch {
        Write-Host "  [!] Nao foi possivel atualizar o JSON do Windows Terminal automaticamente: $_" -ForegroundColor DarkYellow
    }
} else {
    Write-Host "`n[-] Windows Terminal settings.json nao encontrado (ignorado se nao instalado)." -ForegroundColor Gray
}

# 2. Configurar VS Code
$codeUserDir = Join-Path $env:APPDATA "Code\User"
$codeSettings = Join-Path $codeUserDir "settings.json"
$scoopNvim = "$env:USERPROFILE/scoop/apps/neovim/current/bin/nvim.exe"

function Set-JsonConfigSetting {
    param(
        [Parameter(Mandatory=$true)] [string]$Content,
        [Parameter(Mandatory=$true)] [string]$Key,
        [Parameter(Mandatory=$true)] [string]$ValueLiteral
    )

    $escapedKey = [regex]::Escape($Key)
    if ($Content -match "`"$escapedKey`"\s*:") {
        return ($Content -replace "`"$escapedKey`"\s*:\s*([^,\r\n]+)", "`"$Key`": $ValueLiteral")
    } else {
        $lastBraceIndex = $Content.LastIndexOf('}')
        if ($lastBraceIndex -ge 0) {
            $prefix = $Content.Substring(0, $lastBraceIndex).TrimEnd()
            if ($prefix -match '[^{\s]$' -and $prefix -notmatch ',\s*$') {
                $prefix += ","
            }
            return $prefix + "`r`n  `"$Key`": $ValueLiteral`r`n}"
        }
        return "{`r`n  `"$Key`": $ValueLiteral`r`n}"
    }
}

if (Test-Path $codeUserDir) {
    Write-Host "`n[+] Atualizando configuracoes no VS Code..." -ForegroundColor Yellow
    try {
        $content = if (Test-Path $codeSettings) { Get-Content $codeSettings -Raw } else { "{`r`n}" }

        # Configurar fontes no editor
        $content = Set-JsonConfigSetting -Content $content -Key "editor.fontFamily" -ValueLiteral "`"'JetBrainsMono Nerd Font', 'FiraCode Nerd Font', 'Fira Code', 'JetBrains Mono', Consolas, monospace`""
        
        # Configurar fontes no terminal integrado
        $content = Set-JsonConfigSetting -Content $content -Key "terminal.integrated.fontFamily" -ValueLiteral "`"'JetBrainsMono Nerd Font', 'FiraCode Nerd Font', monospace`""

        # Configurar ligaduras de fontes
        $content = Set-JsonConfigSetting -Content $content -Key "editor.fontLigatures" -ValueLiteral "true"

        # Configurar caminho e ativacao do backend Neovim no VS Code
        $content = Set-JsonConfigSetting -Content $content -Key "vim.enableNeovim" -ValueLiteral "true"
        $content = Set-JsonConfigSetting -Content $content -Key "vim.neovimPath" -ValueLiteral "`"$scoopNvim`""

        Set-Content -Path $codeSettings -Value $content -Encoding UTF8
        Write-Host "  [OK] VS Code configurado com fontes Nerd Font, ligaduras e caminho do Neovim!" -ForegroundColor Green
    } catch {
        Write-Host "  [!] Nao foi possivel atualizar o settings.json do VS Code: $_" -ForegroundColor DarkYellow
    }
} else {
    Write-Host "`n[-] Pasta de configuracao do VS Code nao encontrada ($codeUserDir)." -ForegroundColor Gray
}

Write-Host "`n[OK] Ajustes visuais e de terminais concluidos!" -ForegroundColor Green
