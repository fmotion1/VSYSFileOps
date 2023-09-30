function Optimize-SVGWithSVGCleaner {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        $Files,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [Int32]
        $MaxThreads = 24
    )

    begin {
        $List = [System.Collections.Generic.List[String]]@()
    }

    process {
        foreach ($P in $Files) {
            if ($P -is [String]) { $List.Add($P) }
            elseif ($P.Path)     { $List.Add($P.Path) }
            elseif ($P.FullName) { $List.Add($P.FullName) }
            elseif ($P.PSPath)   { $List.Add($P.PSPath) }
            else { Write-Error "$P is an unsupported type."; throw }
        }
    }

    end {

        $List | ForEach-Object -Parallel {

            $CurrentFile = $_
            $CurrentFileName = [System.IO.Path]::GetFileName($CurrentFile)
            $CurrentFolder = [System.IO.Directory]::GetParent($CurrentFile)
            $DestFolder = Join-Path $CurrentFolder "SVGCleaner"

            if (-not(Test-Path -LiteralPath $DestFolder -PathType Container)) {
                New-Item -ItemType Directory -Path $DestFolder -Force | Out-Null
            }

            $DestFile = Join-Path $DestFolder $CurrentFileName

            $CMD = Get-Command svgcleaner.exe
            $Params = '--allow-bigger-file', $CurrentFile, $DestFile
            & $CMD $Params

        } -ThrottleLimit $MaxThreads
    }
}