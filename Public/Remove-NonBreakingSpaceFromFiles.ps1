function Remove-NonBreakingSpaceFromFiles {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeLine)]
        [String[]]$Files
    )

    process {
        foreach ($File in $Files) {
            if($File -match '\u00A0'){
                Write-Verbose "NBSP Detected in $File"
                $newFileName = $File -replace '\u00A0', ' '
                Rename-Item -Path $File -NewName $newFileName -Force
                $newFileName
            }else{
                $File
            }
        }
    }
}