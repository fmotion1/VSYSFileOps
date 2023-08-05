function Remove-NBSPFromFile {
    [CmdletBinding(DefaultParameterSetName = 'FromPath')]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'FromPath', Position = 0, ValueFromPipeline = $true)]
        [string[]]$Path,

        [Parameter(Mandatory = $true, ParameterSetName = 'FromLiteralPath', ValueFromPipelineByPropertyName = $true)]
        [Alias('PSPath')]
        [string[]]$LiteralPath
    )

    process {
        foreach($File in Get-Item @PSBoundParameters) {
            if($File -match '\u00A0') {
                $File | Rename-Item -NewName { $_.Name -replace '\u00A0', ' ' } -Force
            }
        }
    }
}