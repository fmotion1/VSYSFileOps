function Group-ImagesBySingleColor {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        $Files,

        [Parameter(Mandatory)]
        [String]
        $HexColor,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName)]
        [Int32]
        $MaxThreads = 16
    )

    begin {
        $List = @()
    }

    process {
        foreach ($P in $Files) {
            if ($P -is [String]) { $List += $P }
            elseif ($P.Path) { $List += $P.Path }
            elseif ($P.FullName) { $List += $P.FullName }
            elseif ($P.PSPath) { $List += $P.PSPath }
            else { Write-Warning "$P is an unsupported type." }
        }
    }

    end {

        $MatchList = [System.Collections.Generic.List[String]]@()

        $List | ForEach-Object {
            $File  = $_
            $Color = $HexColor
            $Result = & magick -background None $File -scale "1x1^!" -alpha off -depth 8 -define ftxt:format=\H\n ftxt:

            Write-Host "`$File:" $File -ForegroundColor Green
            Write-Host "`$Color:" $Color -ForegroundColor Green
            Write-Host "`$Result:" $Result -ForegroundColor Green

            if($Result -eq $Color){
                $MatchList.Add($File)
            }

        }

        if($MatchList.Count -gt 1){

            $ColorDir = $HexColor.Replace('#', '')
            $Path = Split-Path $MatchList[0] -Parent
            $DestPath = Join-Path $($Path + '\') $ColorDir

            if (!(Test-Path -LiteralPath $DestPath -PathType Container)) {
                $IDX = 2
                $PadIndexTo = '1'
                $StaticFilename = $DestPath
                while (Test-Path -LiteralPath $DestPath -PathType Container) {
                    $DestPath = "{0} {1:d$PadIndexTo}" -f $StaticFilename, $IDX
                    $IDX++
                }

                New-Item -Path $DestPath -ItemType Directory -Force
            }

            $MatchList | ForEach-Object {
                $DestPathFile = Join-Path $DestPath $([IO.Path]::GetFileName($_))
                [IO.File]::Move($_, $DestPathFile)
            }
        }
    }
}