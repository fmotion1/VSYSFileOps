function Optimize-SVGWithSVGO {
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

        $List | ForEach-Object -Parallel {

            $CurrentFile     = $_
            $CurrentFileBase = Get-FilePathComponent -Path $CurrentFile -Component FileBase
            $CurrentFolder   = Get-FilePathComponent -Path $CurrentFile -Component Folder
            $DestFolder      = Join-Path $CurrentFolder "SVGO Optimized"

            if(!(Test-Path -LiteralPath $DestFolder -PathType Container)){
                New-Item -ItemType Directory -Path $DestFolder -Force | Out-Null
            }

            $NewFilename = $CurrentFileBase + ".svg"
            $DestinationFile = Join-Path $DestFolder $NewFilename

            $DestFile = $DestinationFile
            $IDX = 2
            $PadIndexTo = '1'
            $StaticFilename = Get-FilePathComponent $DestFile -Component FullPathNoExtension
            $FileExtension  = Get-FilePathComponent $DestFile -Component FileExtension
            while (Test-Path -LiteralPath $DestFile -PathType Leaf) {
                $DestFile = "{0}_{1:d$PadIndexTo}{2}" -f $StaticFilename, $IDX, $FileExtension
                $IDX++
            }

            & svgo $CurrentFile -o $DestFile

        } -ThrottleLimit $MaxThreads
    }
}