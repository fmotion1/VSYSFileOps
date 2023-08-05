function Rename-FontToActualNameDirectory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        $Directories,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [Switch]
        $Recurse,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [Int32]
        $MaxThreads = 16
    )


    begin {
        & "$env:PYVENV\FontTools\Scripts\Activate.ps1"
        $List = @()
    }

    process {
        foreach ($P in $Directories) {
            if     ($P -is [String]) { $List += $P }
            elseif ($P.Path)         { $List += $P.Path }
            elseif ($P.FullName)     { $List += $P.FullName }
            elseif ($P.PSPath)       { $List += $P.PSPath }
            else                     { Write-Warning "$P is an unsupported type." }
        }
    }

    end {

        $ToProcess = [System.Collections.ArrayList]@()

        foreach ($D in $List) {
            if($Recurse){
                $L = Get-ChildItem -LiteralPath $D -File -Recurse |
                     Where-Object { ($_.Extension -eq '.otf') -or ($_.Extension -eq '.ttf') }
            } else {
                $L = Get-ChildItem -LiteralPath $D -File |
                     Where-Object { ($_.Extension -eq '.otf') -or ($_.Extension -eq '.ttf') }
            }
            if($L){$ToProcess.Add($L)}
        }

        $ToProcess | Rename-FontToActualName

    }
}