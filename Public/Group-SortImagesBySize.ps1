function Group-SortImagesBySize {
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

        Add-Type -AssemblyName System.Drawing

        $List | ForEach-Object -Parallel {

            $ImagePath    = $_
            $ImgDirectory = [IO.Path]::GetDirectoryName($ImagePath)
            $ImgFilename  = [IO.Path]::GetFileName($ImagePath)

            $Image          = [System.Drawing.Image]::FromFile($ImagePath)
            [int]$ImgWidth  = $Image.Width
            [int]$ImgHeight = $Image.Height

            $Image.Dispose()

            if( ($ImgWidth -eq 0) -or $ImgHeight -eq 0){

                $NewFolder = "Invalid Image"

            } else {

                $NewFolder    = "$ImgWidth" + "x" + "$ImgHeight"
                $OutputFolder = Join-Path $ImgDirectory $NewFolder
                $OutputFull   = Join-Path $OutputFolder $ImgFilename

                if (!(Test-Path -LiteralPath $OutputFolder -PathType Container)) {
                    [IO.Directory]::CreateDirectory($OutputFolder)
                }

                $DestFile = $OutputFull

                $IDX = 2
                $PadIndexTo = '1'
                $StaticFilename = Get-FilePathComponent $DestFile -Component FullPathNoExtension
                $FileExtension = Get-FilePathComponent $DestFile -Component FileExtension
                while (Test-Path -LiteralPath $DestFile -PathType Leaf) {
                    $DestFile = "{0}_{1:d$PadIndexTo}{2}" -f $StaticFilename, $IDX, $FileExtension
                    $IDX++
                }

                Write-Host "`$ImagePath:" $ImagePath -ForegroundColor Green
                Write-Host "`$DestFile:" $DestFile -ForegroundColor Green

                [IO.File]::Move($ImagePath, $DestFile)


            }
        } -ThrottleLimit $MaxThreads
    }
}