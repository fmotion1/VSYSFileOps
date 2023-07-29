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
                'Folder'               { Split-Path $P -Parent; }
                'FileBase'             { Split-Path $P -LeafBase; }
                'File'                 { Split-Path $P -Leaf; }
                'FileExtension'        { Split-Path $P -Extension; }
                'FullPathNoExtension'  { [IO.Path]::Combine((Split-Path $P -Parent),(Split-Path $P -LeafBase)); }
                'FullPath'             { $P; }
                'ParentFolder'         { Split-Path (Split-Path $P -Parent) -Parent; }
            }
            $Result
        }
    }
}