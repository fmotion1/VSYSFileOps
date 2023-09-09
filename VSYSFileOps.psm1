$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Recurse )

Foreach ($Import in $Public) {
    Try {
        . $Import.Fullname
    } Catch {
        throw
    }
}