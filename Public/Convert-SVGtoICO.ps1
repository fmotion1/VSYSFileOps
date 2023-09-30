function Convert-SVGtoICO {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        $Files,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [Switch]
        $HonorSub16pxSizes,

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

            $InputSVG = $_
            $SVGW = 0
            $SVGH = 0
            $Undetermined = $false
            $ViewBoxMatch = $false
            $WidthHeightMatch = $false

            [String]$Output = Select-Xml '//*[local-name()="svg"]/@viewBox' -Path $InputSVG | % Node | % '#text'

            if ($Output) {
                $SourceWidth = [single]($Output.Split(" "))[2]
                $SourceHeight = [single]($Output.Split(" "))[3]
                [int]$FinalWidth = [math]::Ceiling($SourceWidth)
                [int]$FinalHeight = [math]::Ceiling($SourceHeight)

                if ( ($FinalWidth -ne 0) -and ($FinalHeight -ne 0) ) {
                    $Undetermined = $false
                    $ViewBoxMatch = $true
                    $SVGW = $FinalWidth
                    $SVGH = $FinalHeight

                } else {
                    $ViewBoxMatch = $false
                }
            } else {
                $ViewBoxMatch = $false
            }

            if (!$ViewBoxMatch) {
                $InputSVG = $_
                [String]$OutputW = Select-Xml '//*[local-name()="svg"]/@width' -Path $InputSVG | ForEach-Object Node | ForEach-Object '#text'
                [String]$OutputH = Select-Xml '//*[local-name()="svg"]/@height' -Path $InputSVG | ForEach-Object Node | ForEach-Object '#text'

                if($OutputW -match '^[\d]+px$') { $OutputW = $OutputW.Replace('px','') }
                if($OutputH -match '^[\d]+px$') { $OutputH = $OutputH.Replace('px','') }

                [int]$FinalW = [math]::Ceiling($OutputW)
                [int]$FinalH = [math]::Ceiling($OutputH)

                if ( ($FinalW -ne 0) -and ($FinalH -ne 0) ) {
                    $Undetermined = $false
                    $WidthHeightMatch = $true
                    $SVGW = $FinalW
                    $SVGH = $FinalH
                } else {
                    $WidthHeightMatch = $false
                    $Undetermined = $true
                }
            }


            $NewSize = 16

            if(($SVGW -gt 0) -and ($SVGH -gt 0)){
                if($Using:HonorSub16pxSizes){
                    if(($SVGW -lt 16) -and ($SVGH -lt 16)){
                        if($SVGW -gt $SVGH){
                            $NewSize = $SVGW
                        }else{
                            $NewSize = $SVGH
                        }
                    }
                }
            }

            rsvg-convert -w $NewSize -h $NewSize -a -f png $InputSVG -o $TempDirName\16.png
            rsvg-convert -w 20 -h 20 -a -f png $InputSVG -o $TempDirName\20.png
            rsvg-convert -w 24 -h 24 -a -f png $InputSVG -o $TempDirName\24.png
            rsvg-convert -w 32 -h 32 -a -f png $InputSVG -o $TempDirName\32.png
            rsvg-convert -w 48 -h 48 -a -f png $InputSVG -o $TempDirName\48.png
            rsvg-convert -w 256 -h 256 -a -f png $InputSVG -o $TempDirName\256.png

            magick convert $TempDirName\16.png -background none -gravity center -extent 16x16 png32:$TempDirName\16.png
            magick convert $TempDirName\20.png -background none -gravity center -extent 20x20 png32:$TempDirName\20.png
            magick convert $TempDirName\24.png -background none -gravity center -extent 24x24 png32:$TempDirName\24.png
            magick convert $TempDirName\32.png -background none -gravity center -extent 32x32 png32:$TempDirName\32.png
            magick convert $TempDirName\48.png -background none -gravity center -extent 48x48 png32:$TempDirName\48.png
            magick convert $TempDirName\256.png -background none -gravity center -extent 256x256 png32:$TempDirName\256.png

            $IconTempName = Get-RandomAlphanumericString -Length 13

            magick convert $TempDirName\16.png $TempDirName\20.png $TempDirName\24.png $TempDirName\32.png $TempDirName\48.png $TempDirName\256.png $TempDirName\$IconTempName.ico

            $DestFile = [System.IO.Path]::GetFileNameWithoutExtension($InputSVG) + ".ico"
            #$DestPath = Get-FilePathComponent -Path $InputSVG -Component Folder
            $DestPathBase = [System.IO.Path]::GetDirectoryName($InputSVG)
            $DestPath = Join-Path $DestPathBase "ICO Conversion"

            if(!(Test-Path -Path $DestPath -PathType Container)){
                New-Item -Path $DestPath -ItemType Directory -Force | Out-Null
            }

            $TempFilePath = [IO.Path]::Combine($TempDirName, "$IconTempName.ico")
            $DestFilePath = [IO.Path]::Combine($DestPath, $DestFile)

            $IDX = 2
            $PadIndexTo = '1'
            $StaticFilename = Get-FilePathComponent $DestFilePath -Component FullPathNoExtension
            $FileExtension  = Get-FilePathComponent $DestFilePath -Component FileExtension
            while (Test-Path -LiteralPath $DestFilePath -PathType Leaf) {
                $DestFilePath = "{0}_{1:d$PadIndexTo}{2}" -f $StaticFilename, $IDX, $FileExtension
                $IDX++
            }

            if (Test-Path -LiteralPath $TempFilePath -PathType leaf) {
                [IO.File]::Move($TempFilePath, $DestFilePath)
            }

            # Write-Host "`$TempDirName:" $TempDirName -ForegroundColor Green

            Remove-Item -LiteralPath $TempDirName -Force -Recurse

        } -ThrottleLimit $MaxThreads
    }
}