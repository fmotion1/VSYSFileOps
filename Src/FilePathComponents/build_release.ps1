dotnet build .\FilePathComponents.csproj --configuration Release
Write-Host -NoNewLine 'Compile complete. Press any key to exit.'
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
