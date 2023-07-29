function Group-SortSVGsBySizeInDirectory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)]
        $Directories,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName)]
        [Int32]
        $MaxThreads = 16
    )

    begin {
        $List = @()
    }

    process {
        foreach ($P in $Directories) {
            if ($P -is [String]) { $List += $P }
            elseif ($P.Path) { $List += $P.Path }
            elseif ($P.FullName) { $List += $P.FullName }
            elseif ($P.PSPath) { $List += $P.PSPath }
            else { Write-Warning "$P is an unsupported type." }
        }
    }

    end {

        $List | ForEach-Object -Parallel {

            $InputDirectory = $_
            $InitialPath = Get-Item -LiteralPath $InputDirectory

            $InitialPath.EnumerateFiles() | & {

                begin {
                    $SVGW = 0
                    $SVGH = 0
                    $Undetermined = $false
                    $ViewBoxMatch = $false
                    $WidthHeightMatch = $false
                }

                process {

                    $CurrentSVG = $_
                    [String]$Output = Select-Xml '//*[local-name()="svg"]/@viewBox' -Path $CurrentSVG | % Node | % '#text'

                    if($Output){
                        $SourceWidth  = [single]($Output.Split(" "))[2]
                        $SourceHeight = [single]($Output.Split(" "))[3]
                        [int]$FinalWidth = [math]::Ceiling($SourceWidth)
                        [int]$FinalHeight = [math]::Ceiling($SourceHeight)

                        if( ($FinalWidth -ne 0) -and ($FinalHeight -ne 0) ){
                            $Undetermined = $false
                            $ViewBoxMatch = $true
                            $SVGW = $FinalWidth
                            $SVGH = $FinalHeight

                            Write-Host "[INFO]: SVG Viewbox Match: $CurrentSVG" -ForegroundColor Green
                            Write-Host "[INFO]: `$SVGW:" $SVGW -ForegroundColor Green
                            Write-Host "[INFO]: `$SVGH:" $SVGH -ForegroundColor Green

                        } else {
                            $ViewBoxMatch = $false
                            Write-Host "[INFO]: SVG Viewbox did not Match: $CurrentSVG" -ForegroundColor Green
                        }
                    }else{
                        $ViewBoxMatch = $false
                    }

                    if(!$ViewBoxMatch){
                        $CurrentSVG = $_
                        [String]$OutputW  = Select-Xml '//*[local-name()="svg"]/@width' -Path $CurrentSVG | % Node | % '#text'
                        [String]$OutputH  = Select-Xml '//*[local-name()="svg"]/@height' -Path $CurrentSVG | % Node | % '#text'
                        [int]$FinalW      = [math]::Ceiling($OutputW)
                        [int]$FinalH      = [math]::Ceiling($OutputH)

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

                    if($Undetermined) {
                        if( (!$WidthHeightMatch) -and (!$ViewBoxMatch) ){
                            $NewFolderName = "00 No Sizing Data"
                        } else {
                            $NewFolderName = "00 Atypical"
                        }
                    } else {
                        $NewFolderName = "$SVGW" + "x" + "$SVGH"
                    }


                    $NewFolderFull = [IO.Path]::Combine($InitialPath.FullName, "$NewFolderName")
                    if(!(Test-Path -LiteralPath $NewFolderFull -PathType Container)){
                        [IO.Directory]::CreateDirectory($NewFolderFull)
                    }

                    $Destination = Join-Path $NewFolderFull $_.Name
                    $DestFile = $Destination

                    $IDX = 2
                    $PadIndexTo = '1'
                    $StaticFilename = Get-FilePathComponent $DestFile -Component FullPathNoExtension
                    $FileExtension  = Get-FilePathComponent $DestFile -Component FileExtension
                    while (Test-Path -LiteralPath $DestFile -PathType Leaf) {
                        $DestFile = "{0}_{1:d$PadIndexTo}{2}" -f $StaticFilename, $IDX, $FileExtension
                        $IDX++
                    }

                    [IO.File]::Move($_, $DestFile)

                    $SVGW = 0; $SVGH = 0;
                    $Undetermined = $false
                }
            }
        } -ThrottleLimit $MaxThreads
    }
}