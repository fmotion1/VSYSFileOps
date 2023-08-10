function Show-GoogleReverseImageSearch {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        $ImageURL
    )

    $EncodedImage = ConvertTo-UrlEncode -URL $ImageURL
    $Query = "https://lens.google.com/uploadbyurl?url=$EncodedImage"

    $BrowserObj = (Get-DefaultBrowser).ImagePath
    Start-Process $BrowserObj $Query

}