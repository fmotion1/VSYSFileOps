$class = @'
public class FilePathComponents
{
    public string ContainingFolder { get;set; }
    public string FileBaseName { get;set; }
    public string FileFullName { get;set; }
    public string FileExtension { get;set; }
    public string FullPathNoExtension { get;set; }
    public string CompletePath { get;set; }
    public string ParentFolder { get;set; }
}
'@
# add class to PowerShell session
Add-Type -TypeDefinition $class

function Get-FilePathComponents {

    [OutputType("FilePathComponents")]

    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        [String[]]
        $Path
    )

    begin {}
    process {
        foreach ($P in $Path) {
            $obj = [FilePathComponents]::new()
            $obj.ContainingFolder     = Split-Path $P -Parent
            $obj.FileBaseName         = Split-Path $P -LeafBase
            $obj.FileFullName         = Split-Path $P -Leaf
            $obj.FileExtension        = Split-Path $P -Extension
            $obj.FullPathNoExtension  = [IO.Path]::Combine((Split-Path $P -Parent), (Split-Path $P -LeafBase))
            $obj.CompletePath         = $P
            $obj.ParentFolder         = Split-Path (Split-Path $P -Parent) -Parent
            $obj
        }
    }
}