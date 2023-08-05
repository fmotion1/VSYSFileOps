using namespace Sytem.Collections.Generic;
function Remove-NonBreakingSpaceFromFilesInList {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeLine)]
        [String]
        $FileList
    )

    process {

        $OutputPath = $FileList
        $Files = Get-Content $FileList

        $NewItems = [List[String]]@()

        foreach ($File in $Files) {

            if($File -match '\u00A0'){
                Write-Host "NBSP Detected in $File" -ForegroundColor White
                $DestFile = $File -replace '\u00A0', ' '
                $IDX = 2
                $PadIndexTo = '2'
                $StaticFilename = Get-FilePathComponent $DestFile -Component FullPathNoExtension
                $FileExtension  = Get-FilePathComponent $DestFile -Component FileExtension
                while (Test-Path -LiteralPath $DestFile -PathType Leaf) {
                    $DestFile = "{0}_{1:d$PadIndexTo}{2}" -f $StaticFilename, $IDX, $FileExtension
                    $IDX++
                }

                Rename-Item -Path $File -NewName $DestFile -Force
                $NewItems.Add($DestFile)
            }else{
                $NewItems.Add($File)
            }
        }

        Remove-Item -LiteralPath $OutputPath -Force
        New-Item -ItemType File -Path $OutputPath -Force | Out-Null

        foreach ($F in $NewItems) {
            $F | Out-File -FilePath $OutputPath -Append
        }

        return $OutputPath
    }
}


