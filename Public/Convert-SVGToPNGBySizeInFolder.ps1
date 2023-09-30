function Convert-SVGToPNGBySizeInFolder {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [String[]]
        $Folders,

        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [String[]]
        $Sizes,

        [Parameter(Mandatory=$false)]
        [Switch]
        $OverwriteFiles
    )

    process {
        $Folders | ForEach-Object {
            $Files = Get-ChildItem $_ -Filter *.svg -Depth 0 | % {$_.FullName}
            Convert-SVGToPNGBySize -Files $Files -Sizes $Sizes -OverwriteFiles:$OverwriteFiles
        }
    }
}