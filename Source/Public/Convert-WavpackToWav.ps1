function Convert-WavpackToWav {
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
            if	   ($P -is [String]) { $List += $P }
            elseif ($P.Path)         { $List += $P.Path }
            elseif ($P.FullName)     { $List += $P.FullName }
            elseif ($P.PSPath)       { $List += $P.PSPath }
            else                     { Write-Warning "$P is an unsupported type." }
        }
    }

    end {
        $List | ForEach-Object -Parallel {

            $CurrentFile = $_

            $Script = "-W", $CurrentFile
            [void] (& WVUNPACK $Script 2>&1 | Tee-Object -Variable ALLOUTPUT)

            $STDERR = $ALLOUTPUT | Where-Object { $_ -is [System.Management.Automation.ErrorRecord] }
            $Filename = Split-Path $CurrentFile -Leaf
            if($LASTEXITCODE -ne 0){
                Write-Error "Error processing $Filename. Exit code is not 0."
                return
            }

        } -ThrottleLimit $MaxThreads
    }
}