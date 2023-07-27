function Group-SortSVGsBySizeWidthHeight {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)]
        $Files,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName)]
        [Int32]
        $MaxThreads = 16
    )

    begin {
        $List = @()
    }

    process {
        foreach ($P in $Files) {
            if ($P -is [String]) { $List += $P }
            elseif ($P.Path) { $List += $P.Path }
            elseif ($P.FullName) { $List += $P.FullName }
            elseif ($P.PSPath) { $List += $P.PSPath }
            else { Write-Warning "$P is an unsupported type." }
        }
    }

    end {

        $List | ForEach-Object -Parallel {

            $InputSVG = $_

            $SVGW = 0
            $SVGH = 0
            $WidthHeightMatch = $false

            $InputSVG = $_
            [String]$OutputW = Select-Xml '//*[local-name()="svg"]/@width' -Path $InputSVG | ForEach-Object Node | ForEach-Object '#text'
            [String]$OutputH = Select-Xml '//*[local-name()="svg"]/@height' -Path $InputSVG | ForEach-Object Node | ForEach-Object '#text'
            [int]$FinalW = [math]::Ceiling($OutputW)
            [int]$FinalH = [math]::Ceiling($OutputH)

            if ( ($FinalW -ne 0) -and ($FinalH -ne 0) ) {
                $WidthHeightMatch = $true
                $SVGW = $FinalW
                $SVGH = $FinalH
            } else {
                $WidthHeightMatch = $false
            }

            if (!$WidthHeightMatch) {
                $NewFolderName = "00 No Sizing Data"
            } else {
                $NewFolderName = "$SVGW" + "x" + "$SVGH"
            }

            $InputSVGDirectory = [IO.Path]::GetDirectoryName($InputSVG)
            $InputSVGFilename  = [IO.Path]::GetFileName($InputSVG)
            $NewFolderFull     = [IO.Path]::Combine($InputSVGDirectory, $NewFolderName)

            if (!(Test-Path -LiteralPath $NewFolderFull -PathType Container)) {
                [IO.Directory]::CreateDirectory($NewFolderFull) | Out-Null
            }

            $Destination = Join-Path $NewFolderFull $InputSVGFilename
            $DestFile = $Destination

            $IDX = 2
            $PadIndexTo = '1'
            $StaticFilename = Get-FilePathComponent $DestFile -Component FullPathNoExtension
            $FileExtension = Get-FilePathComponent $DestFile -Component FileExtension
            while (Test-Path -LiteralPath $DestFile -PathType Leaf) {
                $DestFile = "{0}_{1:d$PadIndexTo}{2}" -f $StaticFilename, $IDX, $FileExtension
                $IDX++
            }

            [IO.File]::Move($_, $DestFile)

            $SVGW = 0; $SVGH = 0;

        } -ThrottleLimit $MaxThreads
    }
}