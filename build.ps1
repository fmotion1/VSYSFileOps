#requires -Module Configuration, @{ ModuleName = "ModuleBuilder"; ModuleVersion = "1.6.0" }

[CmdletBinding()]
param(
    [ValidateSet("Release","Debug")]
    $Configuration = "Release",

    # The version of the output module
    [Alias("ModuleVersion","Version")]
    [string]$SemVer = '1.0.0'

)

Push-Location $PSScriptRoot -StackName BuildTestStack

Remove-Item -LiteralPath "$PSScriptRoot/../../VSYSModulesLive/VSYSFileOps" -Recurse -Force -ErrorAction SilentlyContinue

try {
    $ErrorActionPreference = "Stop"
    Write-Host "## Calling Build-Module" -ForegroundColor Cyan

    $Module = Build-Module -Passthru -SemVer $SemVer

    $Folder = Split-Path $Module.Path
    $Folder

} catch {
    throw $_
} finally {
    Pop-Location -StackName BuildTestStack
}