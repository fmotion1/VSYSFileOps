using namespace System.Collections.Generic
function Convert-SVGToPNGBySize {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        $FileList,

        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [ValidateScript( {
            foreach ($item in $_) {
                if (!($item -match "^\d{1,4}$")) {
                    return $false
                }
            }
            return $true
        }, ErrorMessage = "Invalid size value passed. Each value must be less than five in length and contain only digits.")]
        [String[]]
        $Sizes,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [Int32]
        $MaxThreads = 16
    )

    begin {
        $Files = [List[String]]::new()
    }

    process {
        foreach ($P in $FileList) {
            if	   ($P -is [String]) { $Files.Add($P) }
            elseif ($P.Path)		 { $Files.Add($P.Path) }
            elseif ($P.FullName)	 { $Files.Add($P.FullName) }
            elseif ($P.PSPath)	     { $Files.Add($P.PSPath) }
            else					 { Write-Warning "$P is an unsupported type." }
        }
    }

    end {

        $Files | ForEach-Object -Parallel {

            $TempDirectory = New-TempDirectory -Length 14
            $TempDirName = $TempDirectory.FullName

            $TheSVG = $_
            $TheSVGBaseName = [IO.Path]::GetFileNameWithoutExtension($_)
            # [String]$Output = Select-Xml '//*[local-name()="svg"]/@viewBox' -Path $TheSVG | % Node | % '#text'

            # $SourceWidth  = [Int32]($Output.Split(" "))[2]
            # $SourceHeight = [Int32]($Output.Split(" "))[3]

            $TargetSizes = $Using:Sizes

            $TargetSizes | ForEach-Object {

                $TargetSize   = $_

                # $ScaleRatio   = $TargetSize / [Math]::Max($SourceWidth, $SourceHeight)
                # $TargetWidth  = [Math]::Round($SourceWidth * $ScaleRatio)
                # $TargetHeight = [Math]::Round($SourceHeight * $ScaleRatio)

                $FinalName = $TheSVGBaseName + "-" + $TargetSize + '.png'
                $TempFinalName = Join-Path $TempDirName $FinalName

                $SVGDir = [IO.Path]::GetDirectoryName($TheSVG)
                $SVGDir = Join-Path $SVGDir "Conversion"

                if(!(Test-Path -LiteralPath $SVGDir -PathType Container)){
                    [IO.Directory]::CreateDirectory($SVGDir) | Out-Null
                }

                $DestFinalName = Join-Path $SVGDir $FinalName

                & rsvg-convert -w $TargetSize -h $TargetSize -a -f png $TheSVG -o $TempFinalName | Out-Null


                # & resvg -w $TargetSize -h $TargetSize $TheSVG $TempFinalName

                $DestFile = $DestFinalName
                $IDX = 2
                $PadIndexTo = '1'
                $StaticFilename = Get-FilePathComponent $DestFile -Component FullPathNoExtension
                $FileExtension  = Get-FilePathComponent $DestFile -Component FileExtension
                while (Test-Path -LiteralPath $DestFile -PathType Leaf) {
                    $DestFile = "{0}_{1:d$PadIndexTo}{2}" -f $StaticFilename, $IDX, $FileExtension
                    $IDX++
                }

                Move-Item -LiteralPath $TempFinalName -Destination $DestFile
            }

        } -ThrottleLimit $MaxThreads
    }
}