function Convert-RasterToRaster {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        $Files,

        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [ValidateSet('png','jpg','jpeg','gif','gifnomatte','tif','bmp','bmp3','webp',IgnoreCase=$true)]
        [String]
        $DestFormat,

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

            $Extensions = @{
                png        = 'png'
                jpg        = 'jpg'
                jpeg       = 'jpeg'
                gif        = 'gif'
                gifnomatte = 'gif'
                tif        = 'tif'
                bmp        = 'bmp'
                bmp3       = 'bmp'
                webp       = 'webp'
            }

            $NoAlpha = @('jpg','jpeg')

            $CurFile       = $_
            $CurForm       = ([System.IO.Path]::GetExtension($CurFile)).Replace('.','')
            $DestForm      = ($Using:DestFormat).ToLower()
            $DestExt       = $Extensions[$DestForm]
            $DestFile      = [System.IO.Path]::ChangeExtension($CurFile, $DestExt)
            $DestFileNoExt = Get-FilePathComponent $DestFile -Component FullPathNoExtension

            if($DestForm -eq 'bmp3')       { $DestFile = "$DestFileNoExt BMP3.bmp" }
            if($DestForm -eq 'gifnomatte') { $DestFile = "$DestFileNoExt NoMatte.gif" }
            if($CurForm -eq 'psd') {
                $CurFile = (Get-FilePathComponent $CurFile -Component FullPathNoExtension)+".psd[0]"
            }

            $IDX = 2
            $PadIndexTo = '1'
            $StaticFilename = Get-FilePathComponent $DestFile -Component FullPathNoExtension
            $FileExtension  = Get-FilePathComponent $DestFile -Component FileExtension
            while (Test-Path -LiteralPath $DestFile -PathType Leaf) {
                $DestFile = "{0}_{1:d$PadIndexTo}{2}" -f $StaticFilename, $IDX, $FileExtension
                $IDX++
            }

            if($NoAlpha.Contains($DestForm) -or $NoAlpha.Contains($CurForm)){
                $Script = $CurFile, '-background', 'white', '-flatten', '-alpha', 'off', $DestFile
            } else {
                if($DestForm -eq 'gif'){
                    $Script = $CurFile, '-background', '#FFFFFF', '-flatten',
                                        '-fuzz', '5%', '-transparent', '#FFFFFF', $DestFile
                }elseif($DestForm -eq 'bmp3'){
                    $Script = $CurFile, '-define', 'bmp3:alpha=true', "bmp3:$DestFile"
                }elseif($DestForm -eq 'png'){
                    $Script = $CurFile, "PNG32:$DestFile"
                } else {
                    $Script = $CurFile, $DestFile
                }
            }

            & magick $Script


        } -ThrottleLimit $MaxThreads
    }
}