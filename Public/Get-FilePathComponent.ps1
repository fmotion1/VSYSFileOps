function Get-FilePathComponent {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        [String[]]
        $Path,

        [Parameter(Mandatory,ValueFromPipeline)]
        [ValidateSet( 'Folder','FileBase',
                      'File', 'FileExtension',
                      'FullPathNoExtension', 'FullPath',
                      'ParentFolder', IgnoreCase = $true)]
        [String]
        $Component
    )

    process {
        foreach ($P in $Path) {
            $Result = switch ($Component) {
                'Folder'               { [System.IO.Path]::GetDirectoryName($P) }
                'FileBase'             { [System.IO.Path]::GetFileNameWithoutExtension($P) }
                'File'                 { [System.IO.Path]::GetFileName($P) }
                'FileExtension'        { [System.IO.Path]::GetExtension($P) }
                'FullPathNoExtension'  { [IO.Path]::Combine([System.IO.Path]::GetDirectoryName($P), [System.IO.Path]::GetFileNameWithoutExtension($P)) }
                'FullPath'             { $P }
                'ParentFolder'         { Split-Path (Split-Path $P -Parent) -Parent }
            }
            $Result
        }
    }
}