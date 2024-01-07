function Convert-CropSVGUsingInkscape {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        $Files,
        [Switch] $RenameOutput,
        [Switch] $PlaceInSubfolder,
        [Int32] $MaxThreads = 16
    )

    begin {

        $List = [System.Collections.Generic.List[String]]@()
        
        try {
            $InkscapeCmd = Get-Command inkscape.com -ErrorAction Stop
        }
        catch {
            Write-Error "Fatal: Inkscape isn't available in PATH."
            throw $_
        }
    }

    process {
        foreach ($P in $Files) {

            $Path = if ($P -is [String])  { $P }
                    elseif ($P.Path)	  { $P.Path }
                    elseif ($P.FullName)  { $P.FullName }
                    elseif ($P.PSPath)	  { $P.PSPath }
                    else { Write-Error "$P is an unsupported type."; throw }

            $AbsolutePath = if ([System.IO.Path]::IsPathRooted($Path)) { $Path } 
            else { Resolve-Path -Path $Path }

            if (Test-Path -Path $AbsolutePath) {
                $List.Add($AbsolutePath)
            } else {
                Write-Warning "$AbsolutePath does not exist."
            }
        } 
    }

    end {

        $List | ForEach-Object -Parallel {

            $CurrentSVG = $_
            $RenameOutput = $Using:RenameOutput
            $PlaceInSubfolder = $Using:PlaceInSubfolder
            $FinalOutput = $null

            function Rename-DuplicateSVGs {
                param (
                    [String] $Dest
                )

                $DestFile = $Dest
                $IDX = 2
                $PadIndexTo = '2'
                $StaticFilename = $DestFile.Substring(0, $DestFile.LastIndexOf('.'))
                $FileExtension  = [System.IO.Path]::GetExtension($DestFile)
                while (Test-Path -LiteralPath $DestFile -PathType Leaf) {
                    $DestFile = "{0}_{1:d$PadIndexTo}{2}" -f $StaticFilename, $IDX, $FileExtension
                    $IDX++
                }

                $DestFile
            }

            $DestFilename = [System.IO.Path]::GetFileName($CurrentSVG)
            $FileParent = [System.IO.Directory]::GetParent($CurrentSVG)

            if($RenameOutput) {
                $DestFilename += '_crop.svg'
            }
            $DestFile = $null

            if($PlaceInSubfolder){
                $FileNewDir = [System.IO.Path]::Combine($FileParent, "Cropped")
                if(-not(Test-Path -LiteralPath $FileNewDir -PathType Container)){
                    New-Item -Path $FileNewDir -ItemType Directory -Force | Out-Null
                }
                $DestFile = Join-Path $FileNewDir -ChildPath $DestFilename
            } else {
                $DestFile = Join-Path $FileParent -ChildPath $DestFilename
            }

            if($RenameOutput){
                $FinalOutput = Rename-DuplicateSVGs -Dest $DestFile
            }else{
                $FinalOutput = $DestFile
            }
            
            $Params = '-o', $FinalOutput, '-D', $CurrentSVG
            & $Using:InkscapeCmd $Params | Out-Null

        } -ThrottleLimit $MaxThreads
    }
}
