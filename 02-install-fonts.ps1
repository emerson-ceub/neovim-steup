<#
.SYNOPSIS
    Baixa e instala JetBrains Mono Nerd Font e Fira Code Nerd Font sem privilégios de Administrador.
    Utiliza a pasta de fontes por usuário do Windows 10/11 e registra no HKCU.
#>

$ErrorActionPreference = 'Stop'

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  2. Instalando Nerd Fonts no Usuario   " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

Add-Type -AssemblyName PresentationCore -ErrorAction SilentlyContinue
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class FontRegistrar {
    [DllImport("gdi32.dll", EntryPoint = "AddFontResourceW", SetLastError = true)]
    public static extern int AddFontResource([In][MarshalAs(UnmanagedType.LPWStr)] string lpFileName);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam, uint fuFlags, uint uTimeout, out IntPtr lpdwResult);
}
"@ -ErrorAction SilentlyContinue

$userFontsDir = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Fonts"
if (-not (Test-Path $userFontsDir)) {
    New-Item -ItemType Directory -Path $userFontsDir -Force | Out-Null
}

$tempDir = Join-Path $env:TEMP "nerdfonts_setup"
if (Test-Path $tempDir) {
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
}
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

$fontDownloads = @(
    @{ Name = "JetBrainsMono"; CheckFile = "JetBrainsMonoNerdFont-Regular.ttf"; Url = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" },
    @{ Name = "FiraCode"; CheckFile = "FiraCodeNerdFont-Regular.ttf"; Url = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip" }
)

foreach ($item in $fontDownloads) {
    $fontName = $item.Name
    $checkFilePath = Join-Path $userFontsDir $item.CheckFile

    if (Test-Path $checkFilePath) {
        Write-Host "`n[OK] $fontName Nerd Font ja esta instalada em $userFontsDir. Pulando download." -ForegroundColor Green
        continue
    }

    $zipPath = Join-Path $tempDir "$fontName.zip"
    $fontExtractDir = Join-Path $tempDir $fontName
    New-Item -ItemType Directory -Path $fontExtractDir -Force | Out-Null

    Write-Host "`n[+] Baixando $fontName Nerd Font..." -ForegroundColor Yellow
    curl.exe -sL -o $zipPath $item.Url

    Write-Host "[+] Extraindo $fontName..." -ForegroundColor Yellow
    tar.exe -xf $zipPath -C $fontExtractDir

    $ttfFiles = Get-ChildItem -Path $fontExtractDir -Filter "*.ttf" -Recurse
    Write-Host "[+] Instalando $($ttfFiles.Count) arquivos de fonte para $fontName..." -ForegroundColor Cyan

    foreach ($file in $ttfFiles) {
        $destPath = Join-Path $userFontsDir $file.Name
        if (-not (Test-Path $destPath)) {
            try {
                Copy-Item -Path $file.FullName -Destination $destPath -Force
            } catch {
                continue
            }
        }

        try {
            $typefaces = [System.Windows.Media.Fonts]::GetTypefaces($destPath)
            foreach ($tf in $typefaces) {
                $family = ($tf.FontFamily.FamilyNames.Values | Select-Object -First 1)
                $face = ($tf.FaceNames.Values | Select-Object -First 1)
                $regName = if ($face -and $face -ne "Regular") { "$family $face (TrueType)" } else { "$family (TrueType)" }

                Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts' -Name $regName -Value $destPath -Force -ErrorAction SilentlyContinue
            }
        } catch {
            $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
            $regName = "$baseName (TrueType)"
            Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts' -Name $regName -Value $destPath -Force -ErrorAction SilentlyContinue
        }

        [FontRegistrar]::AddFontResource($destPath) | Out-Null
    }

    # Limpeza dos arquivos temporários dessa fonte
    Remove-Item -Path $fontExtractDir -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path $zipPath -Force -ErrorAction SilentlyContinue
}

# Notifica o Windows sobre a adição das novas fontes
Write-Host "`n[+] Notificando o Windows sobre as fontes ativas..." -ForegroundColor Yellow
$result = [IntPtr]::Zero
[FontRegistrar]::SendMessageTimeout([IntPtr]0xffff, 0x001D, [IntPtr]0, [IntPtr]0, 2, 2000, [ref]$result) | Out-Null

Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "`n[OK] JetBrains Mono e Fira Code Nerd Fonts instaladas e ativas!" -ForegroundColor Green
