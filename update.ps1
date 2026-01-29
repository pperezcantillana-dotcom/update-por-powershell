# ==============================
# Configuración inicial
# ==============================

# Forzar TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$ScriptPath = "C:\Scripts"
$LogFile = "$ScriptPath\WindowsUpdate_$(Get-Date -Format 'yyyyMMdd_HHmm').log"
$ModuleName = "PSWindowsUpdate"

if (-not (Test-Path $ScriptPath)) {
    New-Item -ItemType Directory -Path $ScriptPath -Force
}

Start-Transcript -Path $LogFile -Append
Write-Host "===== Inicio del proceso Windows Update =====" -ForegroundColor Cyan

# ==============================
# Cargar PackageManagement / PowerShellGet
# ==============================

Write-Host "Validando módulos base..." -ForegroundColor Cyan

try {
    Import-Module PackageManagement -ErrorAction Stop
    Import-Module PowerShellGet -ErrorAction Stop
    Write-Host "PackageManagement y PowerShellGet cargados." -ForegroundColor Green
}
catch {
    Write-Host "PowerShellGet no disponible. Instalación manual requerida." -ForegroundColor Yellow

    $psGetUrl = "https://www.powershellgallery.com/api/v2/package/PowerShellGet/2.2.5"
    $psGetZip = "$env:TEMP\PowerShellGet.zip"

    Invoke-WebRequest $psGetUrl -OutFile $psGetZip

    Expand-Archive $psGetZip -DestinationPath "$env:ProgramFiles\WindowsPowerShell\Modules" -Force

    Import-Module PowerShellGet -Force
    Import-Module PackageManagement -Force
}

# ==============================
# Validar proveedor NuGet
# ==============================

if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
    Write-Host "Instalando proveedor NuGet..." -ForegroundColor Yellow
    Install-PackageProvider -Name NuGet -Force
}

# ==============================
# Validar módulo PSWindowsUpdate
# ==============================

if (-not (Get-Module -ListAvailable -Name $ModuleName)) {
    Write-Host "Instalando módulo PSWindowsUpdate..." -ForegroundColor Yellow
    Install-Module -Name $ModuleName -Force -Confirm:$false -Scope AllUsers
} else {
    Write-Host "PSWindowsUpdate ya instalado." -ForegroundColor Green
}

Import-Module PSWindowsUpdate -Force

# ==============================
# Ejecución Windows Update
# ==============================

Write-Host "Buscando actualizaciones..." -ForegroundColor Cyan
Get-WindowsUpdate -Verbose

Write-Host "Instalando actualizaciones..." -ForegroundColor Green
Install-WindowsUpdate -AcceptAll -AutoReboot -Verbose

Write-Host "Proceso finalizado correctamente." -ForegroundColor Cyan
Stop-Transcript
