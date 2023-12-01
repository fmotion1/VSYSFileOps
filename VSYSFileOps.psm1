$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Recurse )

Foreach ($Import in $Public) {
    Try {
        . $Import.Fullname
    } Catch {
        $eMessage = "There was a problem importing $($Import.Fullname)."
        $eRecord = New-Object -TypeName System.Management.Automation.ErrorRecord -ArgumentList (
            (New-Object -TypeName Exception -ArgumentList $eMessage),
            'ModuleDotsourceError',
            [System.Management.Automation.ErrorCategory]::SyntaxError,
            $Import
        )
        $PSCmdlet.ThrowTerminatingError($eRecord)
    }
}