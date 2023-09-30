function Optimize-SVGWithSVGO {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        $Files,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName)]
        [Int32]
        $MaxThreads = 24
    )

    begin {
        $List = [System.Collections.Generic.List[String]]@()
    }

    process {
        foreach ($P in $Files) {
            if ($P -is [String]) { $List.Add($P) }
            elseif ($P.Path) { $List.Add($P.Path) }
            elseif ($P.FullName) { $List.Add($P.FullName) }
            elseif ($P.PSPath) { $List.Add($P.PSPath) }
            else { Write-Error "$P is an unsupported type."; throw }
        }
    }

    end {

        $List | ForEach-Object -Parallel {

            $CurrentFile = $_
            $CMD = Get-Command svgo-win.exe
            $Params = $CurrentFile
            & $CMD $Params

        } -ThrottleLimit $MaxThreads
    }
}