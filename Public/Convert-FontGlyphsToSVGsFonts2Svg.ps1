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
        & "D:\Dev\Python\FontTools\Scripts\Activate.ps1"
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
            $DestPath = Get-FilePathComponent -Path $CurrentFile -Component FullPathNoExtension
            $DestPath = "$DestPath Fonts2SVG"

            if(!(Test-Path -LiteralPath $DestPath -PathType Container)){
                New-Item -Path $DestPath -ItemType Directory -Force
            }

            #$Script = $CurrentFile, '-o', $DestPath

            # & fonts2svg `"$CurrentFile`" -o `"$DestPath`"
            & fonts2svg $CurrentFile -o $DestPath

        } -ThrottleLimit $MaxThreads
    }
}