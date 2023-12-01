function Optimize-SVGWithSVGOInDirectory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        $Folders,

        [Parameter(Mandatory = $false)]
        [Switch]
        $ForceRemoveComments,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName)]
        [Int32]
        $MaxThreads = 24
    )

    begin {
        $List = [System.Collections.Generic.List[string]]@()
        & nvm use 20.8
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

            $SVGOConfigFile = Join-Path -Path $CurrentFolder -ChildPath 'svgo.config.js'

            if (Test-Path -LiteralPath $SVGOConfigFile -PathType Leaf) {
                $Params = '--config=svgo.config.js', $CurrentFile
            } else {
                $Params = $CurrentFile
            }

            $CMD = Get-Command svgo.cmd
            $Params = '-r', '-f', $CurrentFolder
            & $CMD $Params

        } -ThrottleLimit $MaxThreads
    }
}