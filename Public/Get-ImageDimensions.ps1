function Get-ImageDimensions {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [String]
        $ImagePath
    )

    process {

        $Image = [System.Drawing.Image]::FromFile($ImagePath)

        $Width = $Image.Width
        $Height = $Image.Height

        $Image.Dispose()

        [PSCustomObject]@{
            Width  = $Width
            Height = $Height
        }
    }
}