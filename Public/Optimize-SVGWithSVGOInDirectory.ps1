function Optimize-SVGWithSVGOInDirectory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        $Folders,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName)]
        [Int32]
        $MaxThreads = 24
    )

    begin {
        $List = [System.Collections.Generic.List[string]]@()
    }

    process {
        foreach ($P in $Folders) {
            if ($P -is [String]) { $List.Add($P) }
            elseif ($P.Path) { $List.Add($P.Path) }
            elseif ($P.FullName) { $List.Add($P.FullName) }
            elseif ($P.PSPath) { $List.Add($P.PSPath) }
            else { Write-Error "$P is an unsupported type."; throw }
        }
    }

    end {
        $List | ForEach-Object -Parallel {

            $CurrentFolder = $_
            Write-Host "`$CurrentFolder:" $CurrentFolder -ForegroundColor Green
            $CMD = Get-Command svgo-win.exe
            $Params = '-r', '-f', $CurrentFolder 
            & $CMD $Params

        } -ThrottleLimit $MaxThreads
    }
}