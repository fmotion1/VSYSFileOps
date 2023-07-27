function Group-SplitDirectoryContentsToSubfolders {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0)]
        $Directories,

        [Parameter(Mandatory=$false)]
        [Int32]
        $NumFilesPerFolder = 1000,

        [Parameter(Mandatory=$false)]
        [Int32]
        $FolderNumberPadding = 2,

        [Parameter(Mandatory=$false)]
        [String]
        $PathPrefix = '',

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [Int32]
        $MaxThreads = 16
    )

    begin {
        $List = @()
    }

    process {
        foreach ($P in $Directories) {
            if     ($P -is [String]) { $List += $P }
            elseif ($P.Path)         { $List += $P.Path }
            elseif ($P.FullName)     { $List += $P.FullName }
            elseif ($P.PSPath)       { $List += $P.PSPath }
            else                     { Write-Warning "$P is an unsupported type." }
        }
    }

    end {

        foreach ($Dir in $List) {

            $CurrentDirectory = $Dir
            Set-Location -LiteralPath $CurrentDirectory

            $initialPath = Get-Item -LiteralPath $CurrentDirectory
            $newFolder = {
                $NewChunk       = $chunk + 1
                $ChunkFormatted = $NewChunk.ToString().PadLeft($FolderNumberPadding, '0')
                $NewDir         = ("$PathPrefix $ChunkFormatted").Trim()
                [IO.Directory]::CreateDirectory([IO.Path]::Combine($initialPath.FullName, "$NewDir"))
            }
            $initialPath.EnumerateFiles() | & {
                begin   {
                    $i = 0; $chunk = 0
                }
                process {
                    if($i++ % $NumFilesPerFolder -eq 0) {
                        $folder = (& $newFolder).FullName
                        $chunk++
                    }
                    $_.MoveTo("$folder\$($_.Name)")
                }
            }
        }
    }
}