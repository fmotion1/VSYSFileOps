function Convert-RecolorPNG {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        $Files,

        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [String]
        $NewColor,

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
        $List | ForEach-Object -Parallel {

            $ReplacementColor = $Using:NewColor

            $CurrentFile = $_
            $CurrentFilename = Get-FilePathComponent $CurrentFile -Component File
            $CurrentFolder = Get-FilePathComponent $CurrentFile -Component Folder

            $DestFolder = $CurrentFolder
            $DestFile = Join-Path $DestFolder $CurrentFilename

            if(!(Test-Path -LiteralPath $DestFolder -PathType Container)){
                New-Item -Path $DestFolder -ItemType Directory -Force | Out-Null
            }

            # $IDX = 2
            # $PadIndexTo = '1'
            # $StaticFilename = Get-FilePathComponent $DestFile -Component FullPathNoExtension
            # $FileExtension  = Get-FilePathComponent $DestFile -Component FileExtension
            # while (Test-Path -LiteralPath $DestFile -PathType Leaf) {
            #     $DestFile = "{0}_{1:d$PadIndexTo}{2}" -f $StaticFilename, $IDX, $FileExtension
            #     $IDX++
            # }

            $Script = "$CurrentFile", "-fill", "$ReplacementColor", "-colorize", "100", "PNG32:$DestFile"
            & magick mogrify $Script | Out-Null


        } -ThrottleLimit $MaxThreads
    }
}