# Windows Setup Script for Bubbles Qt6 Application
# Requires PowerShell 5.0 or later

param(
    [switch]$SkipChoco,
    [switch]$SkipQt,
    [string]$QtPath = "C:\Qt\6.5.0\msvc2019_64"
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 Bubbles Qt6 Application Setup for Windows" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

# Function to check if running as administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Function to install Chocolatey
function Install-Chocolatey {
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host "✓ Chocolatey is already installed" -ForegroundColor Green
    } else {
        Write-Host "Installing Chocolatey..." -ForegroundColor Yellow
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    }
}

# Function to install required packages
function Install-Dependencies {
    Write-Host "Installing dependencies via Chocolatey..." -ForegroundColor Yellow
    
    choco install git -y
    choco install cmake -y
    choco install visualstudio2019buildtools -y
    choco install visualstudio2019-workload-vctools -y
    
    if (-not $SkipQt) {
        Write-Host "Installing Qt6..." -ForegroundColor Yellow
        choco install qt-creator -y
        # Note: User may need to manually install Qt6 from qt.io
        Write-Host "⚠️  You may need to manually install Qt6 from https://www.qt.io/download" -ForegroundColor Yellow
    }
}

# Function to setup environment variables
function Set-Environment {
    Write-Host "Setting up environment variables..." -ForegroundColor Yellow
    
    # Add Qt to PATH if specified
    if (Test-Path $QtPath) {
        $env:PATH += ";$QtPath\bin"
        $env:Qt6_DIR = "$QtPath\lib\cmake\Qt6"
        Write-Host "✓ Qt6 path configured: $QtPath" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Qt6 path not found: $QtPath" -ForegroundColor Yellow
        Write-Host "Please set Qt6_DIR environment variable manually" -ForegroundColor Yellow
    }
    
    # Add CMake to PATH
    $env:PATH += ";C:\Program Files\CMake\bin"
}

# Function to initialize git submodules
function Initialize-Submodules {
    Write-Host "Initializing Git submodules..." -ForegroundColor Yellow
    git submodule update --init --recursive
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Git submodules initialized" -ForegroundColor Green
    } else {
        Write-Error "Failed to initialize Git submodules"
    }
}

# Function to build the application
function Build-Application {
    Write-Host "Building the application..." -ForegroundColor Yellow
    
    $buildDir = "build\windows-release"
    New-Item -ItemType Directory -Force -Path $buildDir | Out-Null
    Set-Location $buildDir
    
    cmake ..\.. -G "Visual Studio 16 2019" -A x64 -DCMAKE_BUILD_TYPE=Release
    if ($LASTEXITCODE -eq 0) {
        cmake --build . --config Release
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Build completed successfully!" -ForegroundColor Green
        } else {
            Write-Error "Build failed"
        }
    } else {
        Write-Error "CMake configuration failed"
    }
}

# Main execution
try {
    if (-not (Test-Administrator)) {
        Write-Host "⚠️  This script should be run as Administrator for best results" -ForegroundColor Yellow
    }
    
    if (-not $SkipChoco) {
        Install-Chocolatey
        Install-Dependencies
    }
    
    Set-Environment
    Initialize-Submodules
    Build-Application
    
    Write-Host ""
    Write-Host "🎯 To run the application:" -ForegroundColor Green
    Write-Host "   cd build\windows-release\Release" -ForegroundColor White
    Write-Host "   .\BubblesApp.exe" -ForegroundColor White
    Write-Host ""
    Write-Host "📱 Expected behavior:" -ForegroundColor Green
    Write-Host "   • Black 1024×768 window" -ForegroundColor White
    Write-Host "   • Ten initial bubbles with images" -ForegroundColor White
    Write-Host "   • Click to add 5 new bubbles at mouse position" -ForegroundColor White
    Write-Host "   • Physics collisions with walls and other bubbles" -ForegroundColor White
    Write-Host "   • Round clipping with GraphicalEffects mask" -ForegroundColor White
    
} catch {
    Write-Error "Setup failed: $_"
    exit 1
}
