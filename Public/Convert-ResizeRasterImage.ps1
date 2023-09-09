function Convert-ResizeRasterImage {
    [CmdletBinding(DefaultParameterSetName='Percentage')]
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        $Files,

        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [ValidateSet('png','jpg','jpeg','gif','tif','bmp','webp', IgnoreCase=$true)]
        [String]
        $DestFormat,

        [Parameter(Mandatory,ParameterSetName='Percentage',ValueFromPipelineByPropertyName)]
        [ValidateScript({ ($_ -lt 100) -and ($_ -gt 0) })]
        [Int]
        $DestPercentage,

        [Parameter(Mandatory,ParameterSetName='Width',ValueFromPipelineByPropertyName)]
        [ValidateScript({ ($_ -lt 4000) -and ($_ -gt 2) })]
        [Int]
        $DestWidth,

        [Parameter(Mandatory,ParameterSetName='Height',ValueFromPipelineByPropertyName)]
        [ValidateScript({ ($_ -lt 4000) -and ($_ -gt 2) })]
        [Int]
        $DestHeight,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [Int32]
        $MaxThreads = 16
    )

    begin {
        $List = @()
        $DestFormat = $DestFormat.ToLower()

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

            $Image = $_

            $DPercentage = $Using:DestPercentage
            $DWidth      = $Using:DestWidth
            $DHeight     = $Using:DestHeight

            $ImagePath    = [System.IO.Path]::GetDirectoryName($Image) + [System.IO.Path]::DirectorySeparatorChar
            $ImageNewBase = [System.IO.Path]::GetFileNameWithoutExtension($Image)
            $ImageNewExt  = $Using:DestFormat

            switch ($Using:PSCmdlet.ParameterSetName) {
                "Percentage" {
                    $ImageNewSuffix = [System.String]$DPercentage + "%"
                    $ResizeVal = "$DPercentage%"
                }
                "Width" {
                    $ImageNewSuffix = [System.String]$DWidth + "px"
                    $ResizeVal = "x$DWidth"
                }
                "Height" {
                    $ImageNewSuffix = [System.String]$DHeight + "px"
                    $ResizeVal = "y$DHeight"
                }
            }

            $ImageDestName = "{0}{1}_{2}.{3}" -f $ImagePath, $ImageNewBase, $ImageNewSuffix, $ImageNewExt

            $IDX = 2
            $PadIndexTo = '1'
            $StaticFilename = [IO.Path]::Combine((Split-Path $ImageDestName -Parent), (Split-Path $ImageDestName -LeafBase))
            $FileExtension  = [System.IO.Path]::GetExtension($ImageDestName)
            while (Test-Path -LiteralPath $ImageDestName -PathType Leaf) {
                $ImageDestName = "{0}_{1:d$PadIndexTo}{2}" -f $StaticFilename, $IDX, $FileExtension
                $IDX++
            }

            switch ($ImageNewExt) {
                {$_ -match '^(jpe?g)$'}  { $Script = $Image, '-background', 'white', '-flatten', '-alpha', 'off', '-resize', $ResizeVal, $ImageDestName }
                "gif"   { $Script = $Image, '-background', '#FFFFFF', '-flatten', '-fuzz', '5%', '-transparent', '#FFFFFF', '-resize', $ResizeVal, $ImageDestName }
                "png"	{ $Script = $Image, '-resize', $ResizeVal, "PNG32:$ImageDestName" }
                default { $Script = $Image, '-resize', $ResizeVal, $ImageDestName }
            }

            & magick @Script

        } -ThrottleLimit $MaxThreads
    }
}