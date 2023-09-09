class ImageColorDefinition {
    [string] $RGBValue
    [string] $HEXValue
    [string] $PixelCount
    [string] $Image
    [int] $RChannel
    [int] $GChannel
    [int] $BChannel
}

function Get-ImageDominantSingleColor {
    <#
    .SYNOPSIS
        Leverages ImageMagick to get the dominant color of an image.
    #>
    [OutputType([ImageColorDefinition])]

    [CmdletBinding()]
    param (
        [Alias("file","f")]
        [Parameter(Mandatory,ValueFromPipeline)]
        [String[]]
        $ImageFile
    )

    begin {

        $Margs1 = "-background", "None"
        $Margs2 = '-transparent', 'white',
                  "-format", "%c", "-depth", "8", 'histogram:info:'
    }

    process {

        $validExtensions = 'jpg', 'jpeg', 'png', 'gif', 'bmp', 'tiff', 'tif', 'svg'
        $RegEx = '\.(' + ($validExtensions -join '|') + ')$'

        if ($ImageFile -notmatch $RegEx) {
            Write-Error "Invalid file format was passed."
            return
        }

        if ((Test-Path -Path $ImageFile) -eq $false) {
            Write-Error "Image file doesn't exist."
            return
        }

        $Result = & magick $Margs1 $ImageFile $Margs2 | findstr ',255)'
        #$Result
        # Clean up horrible formatting
        #$ResultArr = ($Result -replace "`n", '' -replace "(\s{3,})", "`n").Split("`n")
        #$ResultArr = $ResultArr | Sort-Object -Descending { [int]($_ -replace '(\d+):.*', '$1') } | Where-Object {$_ -ne ''}
        #$ResultArr = ($ResultArr.Count -gt 1) ? ($ResultArr -notmatch '^([1-9]|10):') : ,$ResultArr


        # for($i=0; $i -lt $NumColorsToReturn; $i++){

        #     $Item = $ResultArr[$i]

        #     $Components = $Item.Split(' ')
        #     $RGBValue   = $Components[1].Replace(',255)',')')
        #     $RGBArray   = $RGBValue.TrimEnd(')').TrimStart('(').Split(',')

        #     [ImageColorDefinition]@{
        #         Image      = $ImageFile
        #         RGBValue   = $RGBValue
        #         HEXValue   = $Components[2].TrimEnd("FF")
        #         PixelCount = $Components[0].TrimEnd(':')
        #         RChannel   = [int]$RGBArray[0]
        #         GChannel   = [int]$RGBArray[1]
        #         BChannel   = [int]$RGBArray[2]
        #     }
        # }
    }
}









