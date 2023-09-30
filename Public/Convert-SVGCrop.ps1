function Convert-SVGCrop {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        $Files,

        [Parameter(Mandatory=$false)]
        [Switch]
        $RenameOutput,

        [Parameter(Mandatory=$false)]
        [Switch]
        $CleanOutputWithSVGO,

        [Parameter(Mandatory=$false)]
        [Switch]
        $PlaceInSubfolder,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [Int32]
        $MaxThreads = 16
    )

    begin {
        $List = @()
        $NVMCMD = Get-Command nvm.exe
        & $NVMCMD use 20.7.0
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

        $State = @{}

        $List | ForEach-Object -Parallel {

            $File = $_
            $File = $File.Replace('`[', '[')
            $File = $File.Replace('`]', ']')

            $State = $Using:state

            $DoRenameOutput = $Using:RenameOutput
            $DoPlaceInSubfolder = $Using:PlaceInSubfolder

            $FileNoExt = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($File),
                         [System.IO.Path]::GetFileNameWithoutExtension($File))

            $DestFile = $null

            if($DoPlaceInSubfolder){

                $FileParent = [System.IO.Directory]::GetParent($File)
                $FileName   = [System.IO.Path]::GetFileName($File)
                $FileNewDir = [System.IO.Path]::Combine($FileParent, "Cropped")

                if(-not(Test-Path -LiteralPath $FileNewDir -PathType Container)){
                    New-Item -Path $FileNewDir -ItemType Directory -Force | Out-Null
                }

                $DestFile = [System.IO.Path]::Combine($FileNewDir, $FileName)

            } else {

                if($DoRenameOutput) {
                    $DestFile = $FileNoExt + '_crop.svg'
                    $IDX = 2
                    $PadIndexTo = '2'
                    $StaticFilename = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($DestFile),[System.IO.Path]::GetFileNameWithoutExtension($DestFile))
                    $FileExtension  = [System.IO.Path]::GetExtension($DestFile)
                    while (Test-Path -LiteralPath $DestFile -PathType Leaf) {
                        $DestFile = "{0}_{1:d$PadIndexTo}{2}" -f $StaticFilename, $IDX, $FileExtension
                        $IDX++
                    }
                } else {
                    $DestFile = $File
                }
            }

            $INKSCAPECMD = Get-Command "$env:bin\Inkscape\bin\inkscape.com"
            $Prams = '-o', $DestFile, '-D', $File
            & $INKSCAPECMD $Prams | Out-Null

            $OptimizeDir = (Get-Item -LiteralPath $DestFile).Directory
            $State.DestDirectory = $OptimizeDir

        } -ThrottleLimit $MaxThreads

        if($CleanOutputWithSVGO){
            $SVGOCMD = Get-Command svgo.cmd
            $Params = '-f', $State.DestDirectory
            & $SVGOCMD $Params
        }
    }
}
