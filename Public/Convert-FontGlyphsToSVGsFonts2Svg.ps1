function Convert-FontGlyphsToSVGsFonts2Svg {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        $Files,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [Int32]
        $MaxThreads = 16
    )

    begin {

        & "$env:PYVENV\FontTools\Scripts\Activate.ps1"
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

            $CurrentFile = $_
            $DestPath = [System.IO.Path]::Combine(
                [System.IO.Path]::GetDirectoryName($CurrentFile),
                [System.IO.Path]::GetFileNameWithoutExtension($CurrentFile))

            $DestPath = "$DestPath Fonts2SVG"

            if(!(Test-Path -LiteralPath $DestPath -PathType Container)){
                New-Item -Path $DestPath -ItemType Directory -Force
            }

            $APP = Get-Command "$env:PYVENV\FontTools\Scripts\fonts2svg.exe"
            $Prams = $CurrentFile, "-o", $DestPath
            & $APP $Prams

        } -ThrottleLimit $MaxThreads
    }
}