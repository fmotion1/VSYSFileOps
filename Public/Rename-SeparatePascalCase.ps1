function Rename-SeparatePascalCase {
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

            $File = $_
            $Separated = $File -csplit '(?<=[a-z])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])', -join ' '
            Write-Host "`$Separated:" $Separated -ForegroundColor Green
            [System.IO.File]::Move($File, $Separated)

        } -ThrottleLimit $MaxThreads
    }
}