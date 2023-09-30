function Save-FontsToVersionedFolderMulti {
    [CmdletBinding()]
    param (
        [Alias("f")]
        [Parameter(Mandatory,ValueFromPipeline)]
        $Folders,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [Int32]
        $MaxThreads = 16,

        [Parameter(Mandatory=$false)]
        [Switch]
        $WFR
    )

    begin {
        $List = @()
    }

    process {
        foreach ($P in $Folders) {
            if     ($P -is [String]) { $List += $P }
            elseif ($P.Path)         { $List += $P.Path }
            elseif ($P.FullName)     { $List += $P.FullName }
            elseif ($P.PSPath)       { $List += $P.PSPath }
            else                     { Write-Warning "$P is an unsupported type." }
        }
    }

    end {
        $List | ForEach-Object -Parallel {

            $InputFolder = $_
            $Files = Get-ChildItem $InputFolder | % {$_.FullName}
            Save-FontsToVersionedFolder -Files $Files -MaxThreads 8 -WFR:$WFR

        } -ThrottleLimit $MaxThreads
    }
}