$imgurClass = @'
public class ImgurUploadData
{
    public string ViewLink { get;set; }
    public string ContentType { get;set; }
    public string ImageWidth { get;set; }
    public string ImageHeight { get;set; }
    public string ImageSize { get;set; }
    public string ImageSizeFriendly { get;set; }
    public string DeleteHash { get;set; }
    public string DeleteLink { get;set; }
}
'@

Add-Type -TypeDefinition $imgurClass
function Publish-ImageToImgur {

    [OutputType("ImgurUploadData")]

    [CmdletBinding()]
    param (
        [Alias("i")]
        [Parameter(Mandatory, ValueFromPipeline)]
        $ImageFile,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [String]
        $ClientID
    )

    $headers = @{ "Authorization" = "Client-ID $ClientID" }
    $response = Invoke-RestMethod -ErrorAction Stop -Uri "https://api.imgur.com/3/image" -Method "POST" -Headers $headers -InFile $ImageFile
    $deletehash = $response.data.deletehash

    function Convert-UnitsOfMemoryAuto {
        Param
        (
            [ValidateNotNullOrEmpty()]
            [float]$Value
        )
        Begin{
            $sizes = 'KB','MB','GB','TB','PB'
        }
        Process {
            # New for loop
            for($x = 0;$x -lt $sizes.count; $x++){
                if ($Value -lt [int64]"1$($sizes[$x])"){
                    if ($x -eq 0){
                        return "$Value B"
                    } else {
                        $num = $Value / [int64]"1$($sizes[$x-1])"
                        $num = "{0:N2}" -f $num
                        return "$num $($sizes[$x-1])"
                    }
                }
            }
        }
        End{}
    }

    [ImgurUploadData]@{
        ViewLink    = $response.data.link
        ContentType = $response.data.type
        ImageWidth  = $response.data.width
        ImageHeight = $response.data.height
        ImageSize   = $response.data.size
        ImageSizeFriendly = Convert-UnitsOfMemoryAuto -Value $response.data.size
        DeleteHash  = $deletehash
        DeleteLink  = "https://imgur.com/delete/$deletehash"
    }

}