# Builds Utilla in Release and packages it into a Monke Mod Manager-compatible zip.
# The Microsoft.PowerShell.Archive version floor is required so mmm can read the archive.
#Requires -Modules @{ ModuleName="Microsoft.PowerShell.Archive"; ModuleVersion="1.2.3" }

$ErrorActionPreference = "Stop"

$MyInvocation.MyCommand.Path | Split-Path | Push-Location # Run from this script's directory

try {
    $Name = (Get-ChildItem *.csproj).BaseName

    # Pull the version straight from the source of truth (Constants.cs) so the zip name matches the build.
    $Version = (Select-String -Path "Constants.cs" -Pattern 'Version\s*=\s*"([^"]+)"').Matches[0].Groups[1].Value

    dotnet build -c Release
    if ($LASTEXITCODE -ne 0) { throw "dotnet build failed with exit code $LASTEXITCODE" }

    $DllPath = "bin/Release/netstandard2.1/$Name.dll"
    if (-not (Test-Path $DllPath)) { throw "Build output not found: $DllPath" }

    # Stage the BepInEx folder layout (mmm expects <zip>/BepInEx/plugins/<name>/<file>.dll)
    $Stage = Join-Path ([System.IO.Path]::GetTempPath()) "$Name-BepInEx-stage"
    if (Test-Path $Stage) { Remove-Item $Stage -Recurse -Force }
    New-Item -ItemType Directory -Path (Join-Path $Stage "plugins/$Name") -Force | Out-Null
    Copy-Item $DllPath (Join-Path $Stage "plugins/$Name/")

    $Zip = "$Name-v$Version.zip"
    if (Test-Path $Zip) { Remove-Item $Zip -Force }
    Compress-Archive -Path "$Stage/*" -DestinationPath $Zip
    Remove-Item $Stage -Recurse -Force

    Write-Host "Created $Zip" -ForegroundColor Green
}
finally {
    Pop-Location
}
