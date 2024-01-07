Foreach ($import in @('private', 'public')) {
    Try {
        Get-ChildItem -Path "$PSScriptRoot\$import\*.ps1" | ForEach-Object {
            #Write-Host "Importing $($_.FullName)"
            . $_.FullName
        }
    } Catch {
        $eMessage = "There was a problem importing $($import.Fullname)."
        $eRecord = New-Object -TypeName System.Management.Automation.ErrorRecord -ArgumentList (
            (New-Object -TypeName Exception -ArgumentList $eMessage),
            'ModuleDotsourceError',
            [System.Management.Automation.ErrorCategory]::SyntaxError,
            $import
        )
        $_.FullName
        throw $eRecord
    }
}