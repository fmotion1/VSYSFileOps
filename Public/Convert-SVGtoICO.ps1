function Convert-SVGtoICO {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        $Files,

        [Switch] $HonorSub16pxSizes,
        [Int32] $MaxThreads = 16
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

        $TempDirList = [System.Collections.Generic.List[String]]@()

        $List | ForEach-Object -Parallel {

            $TempDir = New-TempDirectory -Length 15
            $TempDirName = $TempDir.FullName
            $TempDirList.Add($TempDirName)

            $InputSVG = $_
            function Get-SVGDimension($attribute) {
                $dimension = Select-Xml "//*[local-name()='svg']/@$attribute" -Path $InputSVG | % Node | % '#text'
                if ($dimension -match '^[\d]+px$') { $dimension = $dimension.Replace('px','') }
                return [math]::Ceiling($dimension)
            }

            $ViewBoxOutput = Select-Xml '//*[local-name()="svg"]/@viewBox' -Path $InputSVG | % Node | % '#text'
            if ($ViewBoxOutput) {
                $SourceWidth = [single]($ViewBoxOutput.Split(" "))[2]
                $SourceHeight = [single]($ViewBoxOutput.Split(" "))[3]
                $SVGW = [math]::Ceiling($SourceWidth)
                $SVGH = [math]::Ceiling($SourceHeight)
            } else {
                $SVGW = Get-SVGDimension 'width'
                $SVGH = Get-SVGDimension 'height'
            }

            $sizes = 16, 20, 24, 32, 48, 256
            foreach ($size in $sizes) {
                $outputSize = if ($size -eq 16 -and $SVGW -lt 16 -and $SVGH -lt 16 -and $Using:HonorSub16pxSizes) { 
                    [math]::Max($SVGW, $SVGH)
                } else { 
                    $size
                }
                rsvg-convert -w $outputSize -h $outputSize -a -f png $InputSVG -o "$TempDirName\$size.png" | Out-Null
                magick "$TempDirName\$size.png" -background none -gravity center -extent ${size}x${size} png32:"$TempDirName\$size.png" | Out-Null
            }

            $IconTempName = Get-RandomAlphanumericString -Length 15
            magick $($sizes.ForEach{"$TempDirName\$_.png"}) "$TempDirName\$IconTempName.ico" | Out-Null
            

            $DestFile = [System.IO.Path]::GetFileNameWithoutExtension($InputSVG) + ".ico"
            $DestPath = Join-Path -Path ([System.IO.Path]::GetDirectoryName($InputSVG)) -ChildPath "ICO Conversion"
            if (!(Test-Path -Path $DestPath -PathType Container)) {
                New-Item -Path $DestPath -ItemType Directory -Force | Out-Null
            }

            $TempFilePath = [System.IO.Path]::Combine($TempDirName, "$IconTempName.ico")
            $DestFilePath = [System.IO.Path]::Combine($DestPath, $DestFile)

            $IDX = 2
            $StaticFilename = $DestFilePath.Substring(0, $DestFilePath.LastIndexOf('.'))
            $FileExtension  = [System.IO.Path]::GetExtension($DestFilePath)
            while (Test-Path -LiteralPath $DestFilePath -PathType Leaf) {
                $DestFilePath = "{0}_{1:d1}{2}" -f $StaticFilename, $IDX, $FileExtension
                $IDX++
            }

            if (Test-Path -LiteralPath $TempFilePath -PathType leaf) {
                [IO.File]::Move($TempFilePath, $DestFilePath) | Out-Null
            }

        } -ThrottleLimit $MaxThreads

        foreach ($Dir in $TempDirList) {
            Remove-Item -LiteralPath $Dir -Recurse
        }
    }
}