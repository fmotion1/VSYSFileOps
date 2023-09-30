function Get-FilePathComponents {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        [String[]]
        $Path
    )

    begin {}
    process {
        foreach ($P in $Path) {
            [PSCustomObject]@{
                Folder               = [System.IO.Path]::GetDirectoryName($P)
                FileBase             = [System.IO.Path]::GetFileNameWithoutExtension($P)
                File                 = [System.IO.Path]::GetFileName($P)
                FileExtension        = [System.IO.Path]::GetExtension($P)
                FullPathNoExtension  = [IO.Path]::Combine([System.IO.Path]::GetDirectoryName($P), [System.IO.Path]::GetFileNameWithoutExtension($P))
                FullPath             = $P
                ParentFolder         = Split-Path (Split-Path $P -Parent) -Parent
            }
        }
    }
}