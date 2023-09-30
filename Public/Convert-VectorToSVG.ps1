
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

            $CMD = Get-Command "$env:bin\Inkscape\bin\inkscape.com"
            $Prams = $CurrentAIFile, '--export-area-drawing', '--export-plain-svg',
                                     '--export-filename', $OutputSVGFile

            & $CMD $Prams


        } -ThrottleLimit $MaxThreads
    }
}
