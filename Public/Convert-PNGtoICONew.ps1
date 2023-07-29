function Convert-PNGtoICO {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        $Files,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [Int32]
        $PadDuplicatesTo = 2,

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

            $TempDir = New-TempDirectory
            $TempDirName = $TempDir.FullName

            $PNG = $_.Replace('`[', '[')
            $PNG = $PNG.Replace('`]', ']')

            Write-Host "`$PNG:" $PNG -ForegroundColor Green

            $PNGObj = New-Object System.Drawing.Bitmap $PNG
            Write-Host "`$PNGObj: " $PNGObj  -ForegroundColor Green

            $IconTempName = Get-RandomAlphanumericString -Length 11

            if (($PNGObj.Height -lt 16) -or ($PNGObj.Width -lt 16)){
                magick convert $PNG -background none -gravity center -extent 16x16 png32:$TempDirName\16.png
                magick convert $TempDirName\16.png $TempDirName\$IconTempName.ico

            } elseif (($PNGObj.Height -lt 20) -or ($PNGObj.Width -lt 20)) {
                if (($PNGObj.Height -eq 16) -and ($PNGObj.Width -eq 16)) {
                    Copy-Item -LiteralPath $PNG -Destination $TempDirName\16.png
                } else {
                    magick convert $PNG -background none -resize 16x16 -gravity center -extent 16x16 png32:$TempDirName\16.png
                }
                magick convert $TempDirName\16.png $TempDirName\$IconTempName.ico

            } elseif (($PNGObj.Height -lt 24) -or ($PNGObj.Width -lt 24)) {
                if (($PNGObj.Height -eq 20) -and ($PNGObj.Width -eq 20)) {
                    Copy-Item -LiteralPath $PNG -Destination $TempDirName\20.png
                } else {
                    magick convert $PNG -background none -resize 20x20 -gravity center -extent 20x20 png32:$TempDirName\20.png
                }
                magick convert $PNG -background none -resize 16x16 -gravity center -extent 16x16 png32:$TempDirName\16.png

                magick convert $TempDirName\20.png $TempDirName\16.png $TempDirName\$IconTempName.ico

            } elseif (($PNGObj.Height -lt 32) -or ($PNGObj.Width -lt 32)) {
                if (($PNGObj.Height -eq 24) -and ($PNGObj.Width -eq 24)) {
                    Copy-Item -LiteralPath $PNG -Destination $TempDirName\24.png
                } else {
                    magick convert $PNG -background none -resize 24x24 -gravity center -extent 24x24 png32:$TempDirName\24.png
                }
                magick convert $PNG -background none -resize 20x20 -gravity center -extent 20x20 png32:$TempDirName\20.png
                magick convert $PNG -background none -resize 16x16 -gravity center -extent 16x16 png32:$TempDirName\16.png

                magick convert $TempDirName\24.png $TempDirName\20.png $TempDirName\16.png $TempDirName\$IconTempName.ico

            } elseif (($PNGObj.Height -lt 40) -or ($PNGObj.Width -lt 40)) {
                if (($PNGObj.Height -eq 32) -and ($PNGObj.Width -eq 32)) {
                    Copy-Item -LiteralPath $PNG -Destination $TempDirName\32.png
                } else {
                    magick convert $PNG -background none -resize 32x32 -gravity center -extent 32x32 png32:$TempDirName\32.png
                }
                magick convert $PNG -background none -resize 24x24 -gravity center -extent 24x24 png32:$TempDirName\24.png
                magick convert $PNG -background none -resize 20x20 -gravity center -extent 20x20 png32:$TempDirName\20.png
                magick convert $PNG -background none -resize 16x16 -gravity center -extent 16x16 png32:$TempDirName\16.png

                magick convert $TempDirName\32.png $TempDirName\24.png $TempDirName\20.png $TempDirName\16.png $TempDirName\$IconTempName.ico


            } elseif (($PNGObj.Height -lt 64) -or ($PNGObj.Width -lt 64)) {
                if (($PNGObj.Height -eq 48) -and ($PNGObj.Width -eq 48)) {
                    Copy-Item -LiteralPath $PNG -Destination $TempDirName\48.png
                } else {
                    magick convert $PNG -background none -resize 48x48 -gravity center -extent 48x48 png32:$TempDirName\48.png
                }
                magick convert $PNG -background none -resize 32x32 -gravity center -extent 32x32 png32:$TempDirName\32.png
                magick convert $PNG -background none -resize 24x24 -gravity center -extent 24x24 png32:$TempDirName\24.png
                magick convert $PNG -background none -resize 20x20 -gravity center -extent 20x20 png32:$TempDirName\20.png
                magick convert $PNG -background none -resize 16x16 -gravity center -extent 16x16 png32:$TempDirName\16.png

                magick convert $TempDirName\48.png $TempDirName\32.png $TempDirName\24.png $TempDirName\20.png $TempDirName\16.png $TempDirName\$IconTempName.ico

            } elseif (($PNGObj.Height -lt 250) -or ($PNGObj.Width -lt 250)) {
                if (($PNGObj.Height -eq 128) -and ($PNGObj.Width -eq 128)) {
                    Copy-Item -LiteralPath $PNG -Destination "$TempDirName\128.png"
                } else {
                    magick convert $PNG -background none -resize 128x128 -gravity center -extent 128x128 png32:$TempDirName\128.png
                }
                magick convert $PNG -background none -resize 48x48 -gravity center -extent 48x48 png32:$TempDirName\48.png
                magick convert $PNG -background none -resize 32x32 -gravity center -extent 32x32 png32:$TempDirName\32.png
                magick convert $PNG -background none -resize 24x24 -gravity center -extent 24x24 png32:$TempDirName\24.png
                magick convert $PNG -background none -resize 20x20 -gravity center -extent 20x20 png32:$TempDirName\20.png
                magick convert $PNG -background none -resize 16x16 -gravity center -extent 16x16 png32:$TempDirName\16.png

                magick convert $TempDirName\128.png $TempDirName\48.png $TempDirName\32.png $TempDirName\24.png $TempDirName\20.png $TempDirName\16.png $TempDirName\$IconTempName.ico

            } elseif (($PNGObj.Height -ge 250) -or ($PNGObj.Width -ge 250)) {
                if (($PNGObj.Height -eq 256) -and ($PNGObj.Width -eq 256)) {
                    Copy-Item -LiteralPath $PNG -Destination "$TempDirName\256.png"
                } else {
                    magick convert $PNG -background none -resize 256x256 -gravity center -extent 256x256 png32:$TempDirName\256.png
                }
                magick convert $PNG -background none -resize 128x128 -gravity center -extent 128x128 png32:$TempDirName\128.png
                magick convert $PNG -background none -resize 48x48 -gravity center -extent 48x48 png32:$TempDirName\48.png
                magick convert $PNG -background none -resize 32x32 -gravity center -extent 32x32 png32:$TempDirName\32.png
                magick convert $PNG -background none -resize 24x24 -gravity center -extent 24x24 png32:$TempDirName\24.png
                magick convert $PNG -background none -resize 20x20 -gravity center -extent 20x20 png32:$TempDirName\20.png
                magick convert $PNG -background none -resize 16x16 -gravity center -extent 16x16 png32:$TempDirName\16.png

                magick convert $TempDirName\256.png $TempDirName\128.png $TempDirName\48.png $TempDirName\32.png $TempDirName\24.png $TempDirName\20.png $TempDirName\16.png $TempDirName\$IconTempName.ico
            }

            $DestPath = [System.IO.Path]::GetDirectoryName($PNG)
            $DestFile = [System.IO.Path]::GetFileNameWithoutExtension($PNG) + ".ico"

            $TempFilePath = [IO.Path]::Combine($TempDirName, "$IconTempName.ico")
            $DestFilePath = [IO.Path]::Combine($DestPath, $DestFile)


            $IDX = 2
            $PadIndexTo = "$Using:PadDuplicatesTo"

            $StaticFilename = Get-FilePathComponent $DestFile -Component FullPathNoExtension
            $FileExtension  = Get-FilePathComponent $DestFile -Component FileExtension

            while (Test-Path -LiteralPath $DestFilePath -PathType Leaf) {
                $DestFilePath = "{0} {1:d$PadIndexTo}{2}" -f $StaticFilename, $IDX, $FileExtension
                $IDX++
            }

            if (Test-Path -LiteralPath $TempFilePath -PathType Leaf) {
                [IO.File]::Move($TempFilePath, $DestFilePath)
            }

            Remove-Item -LiteralPath $TempDirName -Force -Recurse

        } -ThrottleLimit $MaxThreads
    }
}