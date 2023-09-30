function Convert-SVGToPNGBySize {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        $Files,

        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [String[]]
        $Sizes,

        [Parameter(Mandatory=$false)]
        [Switch]
        $OverwriteFiles,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [Int32]
        $MaxThreads = 16
    )

    begin {
        $List = [System.Collections.Generic.List[String]]::new()
        $Sizes | ForEach-Object {
            if($_ -notmatch "^\d{1,4}$"){
                Write-Error "Invalid value passed to Sizes parameter."
                return
            }
        }
    }

    process {
        foreach ($P in $Files) {
            if	   ($P -is [String]) { $List.Add($P) }
            elseif ($P.Path)		 { $List.Add($P.Path) }
            elseif ($P.FullName)	 { $List.Add($P.FullName) }
            elseif ($P.PSPath)	     { $List.Add($P.PSPath) }
            else					 { Write-Warning "$P is an unsupported type." }
        }
    }

    end {

        $List | ForEach-Object -Parallel {

            $SVGFileInput = $_
            $SVGFileBase  = [IO.Path]::GetFileNameWithoutExtension($_)
            $TargetSizes  = $Using:Sizes
            $doOverwrite  = $Using:OverwriteFiles

            $CMD = Get-Command "$env:bin\rsvg-convert.exe"

            $TargetSizes | ForEach-Object {

                $TargetSize = $_
                $DestDirectory = Join-Path ([IO.Path]::GetDirectoryName($SVGFileInput)) "Conversion $TargetSize"

                if(-not(Test-Path -LiteralPath $DestDirectory -PathType Container)){
                    [IO.Directory]::CreateDirectory($DestDirectory) | Out-Null
                }

                $FinalPNGOutput = Join-Path $DestDirectory ($SVGFileBase + "-" + $TargetSize + '.png')

                if(-not($doOverwrite)){
                    $IDX = 2
                    $PadIndexTo = '1'
                    $StaticFilename = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($FinalPNGOutput),
                                      [System.IO.Path]::GetFileNameWithoutExtension($FinalPNGOutput))
                    $FileExtension  = [System.IO.Path]::GetExtension($FinalPNGOutput)
                    while (Test-Path -LiteralPath $FinalPNGOutput -PathType Leaf) {
                        $FinalPNGOutput = "{0}_{1:d$PadIndexTo}{2}" -f $StaticFilename, $IDX, $FileExtension
                        $IDX++
                    }
                }

                $Params = '-w', $TargetSize, '-h', $TargetSize, '-a', '-f', 'png', $SVGFileInput, '-o', $FinalPNGOutput

                & $CMD $Params | Out-Null

            }

        } -ThrottleLimit $MaxThreads
    }
}