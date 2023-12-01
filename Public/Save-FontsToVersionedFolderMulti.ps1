function Save-FontsToVersionedFolderMulti {
    [CmdletBinding()]
    param (
        [Alias("f")]
        [Parameter(Mandatory,ValueFromPipeline)]
        $Folders,

        [Parameter(Mandatory=$false)]
        [Switch]
        $Versioned,

        [Parameter(Mandatory=$false)]
        [Switch]
        $WFR,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [Int32]
        $MaxThreads = 16
    )

    begin {

        try {
            
            & "$env:PYVENV\FontTools\Scripts\Activate.ps1"
            $List = [System.Collections.Generic.List[String]]@()
        
        } catch {
        
            $PSCmdlet.ThrowTerminatingError($PSItem)
        
        }
    }

    process {
        
        try {
            foreach ($P in $Folders) {
                if ($P -is [String]) { $List.Add($P) }
                elseif ($P.Path)     { $List.Add($P.Path) }
                elseif ($P.FullName) { $List.Add($P.FullName) }
                elseif ($P.PSPath)   { $List.Add($P.PSPath) }
                else { Write-Error "Invalid argument passed to files parameter." }
            }
        } catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }

    end {

        $List | ForEach-Object -Parallel {

            $InputFolder = $_
            $DoVersioned = $Using:Versioned
            $DoWFR = $Using:WFR

            $Files = Get-ChildItem $InputFolder | % {$_.FullName}
            Save-FontsToVersionedFolder -Files $Files -Versioned:$DoVersioned -WFR:$DoWFR -MaxThreads 8 

        } -ThrottleLimit $MaxThreads
    }
}