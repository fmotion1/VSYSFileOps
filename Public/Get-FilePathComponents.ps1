function Get-FilePathComponents {

    [CmdletBinding()]
    [OutputType([VSYSStructs.FilePathComponents])]
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        [String[]]
        $Path
    )

    begin {}
    process {
        foreach ($P in $Path) {
            $Components = [VSYSStructs.FilePathComponents]::new()
            $Components.Folder              = [System.IO.Path]::GetDirectoryName($P)
            $Components.FileBase            = [System.IO.Path]::GetFileNameWithoutExtension($P)
            $Components.File                = [System.IO.Path]::GetFileName($P)
            $Components.FileExtension       = [System.IO.Path]::GetExtension($P)
            $Components.FullPathNoExtension = [IO.Path]::Combine([System.IO.Path]::GetDirectoryName($P), [System.IO.Path]::GetFileNameWithoutExtension($P))
            $Components.FullPath            = $P
            $Components.ParentFolder        = Split-Path (Split-Path $P -Parent) -Parent
            $Components
            # [PSCustomObject]@{
            #     Folder               = [System.IO.Path]::GetDirectoryName($P)
            #     FileBase             = [System.IO.Path]::GetFileNameWithoutExtension($P)
            #     File                 = [System.IO.Path]::GetFileName($P)
            #     FileExtension        = [System.IO.Path]::GetExtension($P)
            #     FullPathNoExtension  = [IO.Path]::Combine([System.IO.Path]::GetDirectoryName($P), [System.IO.Path]::GetFileNameWithoutExtension($P))
            #     FullPath             = $P
            #     ParentFolder         = Split-Path (Split-Path $P -Parent) -Parent
            # }
        }
    }
}