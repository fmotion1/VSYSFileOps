function Remove-NBSPFromFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [String]
        $Files
    )

    process {
        foreach($File in $Files) {
            if($File -match '\u00A0') {
                Write-Output "NBSP was found and removed in $File."
                $File | Rename-Item -NewName { $_.Name -replace '\u00A0', '' } -Force
            }
        }
    }
}