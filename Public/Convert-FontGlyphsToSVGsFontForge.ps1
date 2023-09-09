function Convert-FontGlyphsToSVGsFontForge {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        $Files,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [Int32]
        $MaxThreads = 16
    )

    begin {
        $List = @()
    }

    process {
        foreach ($P in $Files) {
            if     ($P -is [String]) { $List += $P }
            elseif ($P.Path)         { $List += $P.Path }
            elseif ($P.FullName)     { $List += $P.FullName }
            elseif ($P.PSPath)       { $List += $P.PSPath }
            else                     { Write-Warning "$P is an unsupported type." }
        }
    }

    end {

        $List | ForEach-Object {

            $CurrentFile = $_
            $DestPath = "FontForge Export"
            if(!(Test-Path -LiteralPath $DestPath -PathType Container)){
                New-Item -Path $DestPath -ItemType Directory -Force | Out-Null
            }

            $APP = "$env:FONTFORGEBIN\fontforge.exe"
            & $APP -lang=ff -c 'Open($1); SelectAll(); UnlinkReference(); Export("FontForge Export/%n-%e.svg");' $CurrentFile

            $CurrentFile = $_
            $FullNoExt = [IO.Path]::GetFileNameWithoutExtension($CurrentFile)
            $DestFolder =  "$FullNoExt FontForge Export"

            Rename-Item -LiteralPath $DestPath -NewName $DestFolder

        }
    }
}