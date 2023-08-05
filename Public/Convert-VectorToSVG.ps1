
function Convert-VectorToSVG {
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
            elseif ($P.Path)		 { $List += $P.Path }
            elseif ($P.FullName)	 { $List += $P.FullName }
            elseif ($P.PSPath)	     { $List += $P.PSPath }
            else					 { Write-Warning "$P is an unsupported type." }
        }
    }

    end {

        $List | ForEach-Object -Parallel {

            $InputFile     = $_
            $CurrentAIFile = $InputFile.Replace('`[', '[')
            $CurrentAIFile = $CurrentAIFile.Replace('`]', ']')
            $OutputSVGFile = [IO.Path]::ChangeExtension($CurrentAIFile, ".svg")

            $App   = "$env:bin\inkscape-1.3\bin\inkscape.com"
            $Args1 = $CurrentAIFile, '--export-area-drawing'
            $Args2 = '--export-plain-svg', '--export-filename', $OutputSVGFile
            [void] (& $App $Args1 $Args2 2>&1 | Tee-Object -Variable ALLOUTPUT)

            $STDERR = $ALLOUTPUT | Where-Object { $_ -is [System.Management.Automation.ErrorRecord] }
            $Filename = Split-Path $CurrentAIFile -Leaf

            if($STDERR.length -gt 0){
                Write-Error "Error processing $Filename. Errors were encountered:"
                foreach ($E in $STDERR) {
                    Write-Error "StdErr: $E"
                }
                return
            }

        } -ThrottleLimit $MaxThreads
    }
}
