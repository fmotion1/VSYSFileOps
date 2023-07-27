function Convert-VectorToRaster {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        $Files,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [ValidateSet('png','jpg','gif','tif8','tif16','bmp',IgnoreCase=$true)]
        [String]
        $DestFormat='png',

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [Switch]
        $SaveAllPages,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [Int]
        $DPI = 800,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [Int32]
        $MaxThreads = 16
    )

    begin {
        $List = @()
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

        $List | ForEach-Object -Parallel {

            $Extensions = @{
                png        = 'png'
                jpg        = 'jpg'
                gif        = 'gif'
                tif8       = 'tif'
                tif16      = 'tif'
                bmp        = 'bmp'
            }

            $TempDirectory     = (New-TempDirectory -Length 10).FullName

            $DPIVal            = $Using:DPI
            $AllPages          = $Using:SaveAllPages

            $OrigFile          = $_
            $OrigFormat        = (([System.IO.Path]::GetExtension($OrigFile)).Replace('.', '')).ToLower()
            $OrigFileBase      = Get-FilePathComponent $OrigFile -Component FileBase

            if((!$AllPages) -and (($OrigFormat -eq 'ai') -or ($OrigFormat -eq 'eps') -or ($OrigFormat -eq 'pdf'))){
                $OrigFile = "$OrigFile[0]"
            }

            $DFormat           = ($Using:DestFormat).ToLower()
            $DExt              = $Extensions[$DFormat]


            switch ($DFormat) {
                'tif8'  { $DFileBase = $OrigFileBase + ' 8Bit'; break }
                'tif16' { $DFileBase = $OrigFileBase + ' 16Bit'; break }
                default { $DFileBase = $OrigFileBase; break }
            }

            $DFile = [IO.Path]::Combine($TempDirectory, "$DFileBase.$DExt")

            switch ($DFormat) {
                'tif8'  { $Script1 = '-background', 'none'; break}
                'tif16' { $Script1 = '-background', 'none'; break}
                'jpg'   { $Script1 = '-background', 'white'; break}
                default { $Script1 = '-background', 'none'; break}
            }

            $Script2 = '-colorspace', 'rgb', '-density', $DPIVal, $OrigFile

            switch ($DFormat) {
                'tif8'  { $Script3 = '-resize', '100%', '-depth', '8', '-compress', 'zip', $DFile; break }
                'tif16' { $Script3 = '-resize', '100%', '-depth', '16', '-compress', 'zip', $DFile; break }
                'jpg'   { $Script3 = '-alpha', 'remove', '-resize', '100%', '-depth', '16', '-compress', 'zip', $DFile; break }
                default { $Script3 = '-resize', '100%', $DFile; break }
            }


            & magick $Script1 $Script2 $Script3

            $TempFiles = Get-ChildItem -LiteralPath $TempDirectory
            foreach ($CurrentFile in $TempFiles) {

                $DestFile = [IO.Path]::Combine($OrigFileDirectory,
                (Get-FilePathComponent $CurrentFile -Component File))

                $IDX = 2
                $PadIndexTo = '1'
                $StaticFilename = Get-FilePathComponent $DestFile -Component FullPathNoExtension
                $FileExtension  = Get-FilePathComponent $DestFile -Component FileExtension
                while (Test-Path -LiteralPath $DestFile -PathType Leaf) {
                    $DestFile = "{0}_{1:d$PadIndexTo}{2}" -f $StaticFilename, $IDX, $FileExtension
                    $IDX++
                }

                Move-Item -LiteralPath $CurrentFile -Destination $DestFile
            }

        } -ThrottleLimit $MaxThreads
    }
}