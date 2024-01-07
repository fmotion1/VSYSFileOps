<#
.SYNOPSIS
NOTE: This function is depreciated. Using Den4b Renamer is much faster.

Renames files by separating PascalCase or camelCase words with spaces.

.DESCRIPTION
The Rename-SeparatePascalCase function renames files by inserting a space between each word in a PascalCase or camelCase filename. It can process a single file, multiple files, or the contents of a folder.

.PARAMETER Files
A collection of files, or a single file to process.

.PARAMETER ProcessFolderContents
If this switch is set, the function will process the contents of the folders specified in the Files parameter.

.PARAMETER MaxThreads
The maximum number of threads to use for the operation. Default is 16.

.EXAMPLE
Rename-SeparatePascalCase -Files "C:\Temp\MyPascalCaseFile.txt"

This will rename the file "MyPascalCaseFile.txt" to "My Pascal Case File.txt".

.EXAMPLE
Rename-SeparatePascalCase -Files "C:\Temp\MyPascalCaseFile.txt", "C:\Temp\AnotherPascalCaseFile.txt"

This will rename the files "MyPascalCaseFile.txt" and "AnotherPascalCaseFile.txt" to "My Pascal Case File.txt" and "Another Pascal Case File.txt" respectively.

.EXAMPLE
Rename-SeparatePascalCase -Files "C:\Temp" -ProcessFolderContents

This will rename all the files in the "C:\Temp" folder, inserting a space between each word in the filenames.

.INPUTS
System.String[], System.Boolean, System.Int32

.OUTPUTS
None

.NOTES
Author: Futuremotion
Website: https://www.github.com/fmotion1

.LINK
https://www.github.com/fmotion1
#>

function Rename-SeparatePascalCase {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position=0,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   HelpMessage="A collection of files, or a single file to process.")]
        [ValidateNotNullOrEmpty()]
        [Object[]] $Files,
        [Switch] $ProcessFolderContents,
        [Int32] $MaxThreads = 16
        
    )

    begin {
        $List = [System.Collections.Generic.List[String]]@()
    }

    process {

        foreach ($P in $Files) {
            $Path = if     ($P -is [String]) { $P }
                    elseif ($P.Path)         { $P.Path }
                    elseif ($P.FullName)     { $P.FullName }
                    elseif ($P.PSPath)       { $P.PSPath }
                    else { Write-Error "$P is an unsupported type."; throw }

            $AbsolutePath = if ([System.IO.Path]::IsPathRooted($Path)) { $Path } 
            else { Resolve-Path -Path $Path }

            if (Test-Path -LiteralPath $AbsolutePath) {
                if($ProcessFolderContents){
                    if (Test-Path -LiteralPath $AbsolutePath -PathType Container){
                        $List.Add($AbsolutePath)
                    }
                }else{
                    $List.Add($AbsolutePath)
                }
            } else {
                Write-Warning "$AbsolutePath does not exist."
            }
        }

        if($List.Count -eq 0) {
            Write-Error "No files to process. List is empty."
        }
    }
    
    end {

        if($ProcessFolderContents) {
            $FileList = [System.Collections.Generic.List[String]]@()
            $isEmpty = $true
            foreach ($Folder in $List) {
                try {
                    $FilesItems = Get-ChildItem -LiteralPath $Folder -Recurse -File
                    if($FilesItems){
                        $isEmpty = $false
                        $Files = $FilesItems | ForEach-Object { $_.FullName }
                        foreach ($File in $Files) {
                            $FileList.Add($File)
                        }
                    }
                } catch {
                    Write-Error "Error processing folder $Folder`: $_"
                }
            }
        
            if($isEmpty){
                Write-Host -f Red "Error: All folders passed in are empty."
            }

            $List = $FileList
        }

        $List | ForEach-Object -Parallel {

            $File = $_
            $FileDir  = [System.IO.Directory]::GetParent($File)
            $Filename = [System.IO.Path]::GetFileNameWithoutExtension($File)
            $FileExt  = [System.IO.Path]::GetExtension($File).Trim()
            $SeparatedFilename = $Filename -csplit "(?<=[a-z])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])|(?<=[0-9])(?=[A-Z][a-z])|(?<=[a-z])(?=[0-9])" -join ' '
            $SeparatedFilename = $SeparatedFilename + $FileExt
            $SeparatedFile = Join-Path $FileDir -ChildPath $SeparatedFilename
            
            if($File -ne $SeparatedFile){
                if(Test-Path -LiteralPath $File -PathType Leaf){
                    [System.IO.File]::Move($File, $SeparatedFile)
                } else {
                    [System.IO.Directory]::Move($File, $SeparatedFile)
                }
            }

        } -ThrottleLimit $MaxThreads
         
    }
}

