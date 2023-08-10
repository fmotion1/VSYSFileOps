$Class = @'
public class ImageColorDefinition
{
    public string RGBValue { get;set; }
    public string HEXValue { get;set; }
    public string PixelCount { get;set; }
    public string Image { get;set; }
    public int RChannel { get;set; }
    public int GChannel { get;set; }
    public int BChannel { get;set; }
}
'@

Add-Type -TypeDefinition $Class

function Get-ImageDominantColor {
    <#
    .SYNOPSIS
        Leverages ImageMagick to get the dominant color of an image.
    #>
    [OutputType("ImageColorDefinition")]

    [CmdletBinding()]
    param (
        [Alias("file","f")]
        [Parameter(Mandatory,ValueFromPipeline)]
        [String[]]
        $ImageFile,

        [Alias("colors","c")]
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [Int32]
        $NumColorsToReturn = 3
    )

    begin {

        $Margs1 = "-background", "None"
        $Margs2 = "-fuzz", '10%', '-transparent', '#ffffff',
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

        # Clean up horrible formatting
        $ResultArr = ($Result -replace "`n", '' -replace "(\s{3,})", "`n").Split("`n")
        $ResultArr = $ResultArr | Sort-Object -Descending { [int]($_ -replace '(\d+):.*', '$1') } | Where-Object {$_ -ne ''}
        $ResultArr = ($ResultArr.Count -gt 1) ? ($ResultArr -notmatch '^([1-9]|10):') : ,$ResultArr

        if($ResultArr.Count -lt $NumColorsToReturn) {
            Write-Warning "The number of colors to return ($NumColorsToReturn) specified is larger than the colors detected in the image."
            $NumColorsToReturn = $ResultArr.Count
        }

        for($i=0; $i -lt $NumColorsToReturn; $i++){

            $Item = $ResultArr[$i]

            $Components = $Item.Split(' ')
            $RGBValue   = $Components[1].Replace(',255)',')')
            $RGBArray   = $RGBValue.TrimEnd(')').TrimStart('(').Split(',')

            [ImageColorDefinition]@{
                Image      = $ImageFile
                RGBValue   = $RGBValue
                HEXValue   = $Components[2].TrimEnd("FF")
                PixelCount = $Components[0].TrimEnd(':')
                RChannel   = [int]$RGBArray[0]
                GChannel   = [int]$RGBArray[1]
                BChannel   = [int]$RGBArray[2]
            }
        }
    }
}









