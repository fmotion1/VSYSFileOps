using namespace System.IO
function Save-FontsToFolder {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        $Files,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [Int32]
        $MaxThreads = 16
    )

    begin {

        & "D:\Dev\Python\00 VENV\FontTools\Scripts\Activate.ps1"
        $VersionScript = "D:\Dev\Python\Font Scripts\GetFontVersion.py"

        $List = @()
    }

    process {
        foreach ($P in $Files) {
            if     ($P -is [String]) { $List += $P }
            elseif ($P.Path)         { $List += $P.Path }
            elseif ($P.FullName)     { $List += $P.FullName }
            elseif ($P.PSPath)       { $List += $P.PSPath }
            else                     { Write-Warning "$P is an unsupported type." }
        }
    }

    end {

        $List | ForEach-Object -Parallel {

            $FontFile  = $_
            $FontFileC = Get-FilePathComponents -Path $FontFile

            $FontFileName      = $FontFileC.FileFullName
            $FontDirectory     = $FontFileC.ContainingFolder
            $FontExtension     = $FontFileC.FileExtension

            $FontFileVersion = & python $Using:VersionScript $FontFile


            # Insert the first word occuring in the filename
            # as a prefixed subdirectory
            $FontExtTrim = $FontExtension.TrimStart('.')
            $Subfolder = switch ($FontExtTrim) {
                "otf"    {'OT'; break}
                "ttf"    {"TT"; break}
                "svg"	 {"WEB"; break}
                "woff2"	 {"WEB"; break}
                "woff"	 {"WEB"; break}
                "eot"	 {"WEB"; break}
                "css"	 {"WEB"; break}
                "html"	 {"WEB"; break}
                "htm"	 {"WEB"; break}
                "ai"	 {"Supplimental"; break}
                "eps"	 {"Supplimental"; break}
                "doc"	 {"Supplimental"; break}
                "txt"	 {"Supplimental"; break}
                "pdf"	 {"Supplimental"; break}
                "jpg"	 {"Supplimental"; break}
                "jpeg"	 {"Supplimental"; break}
                "gif"	 {"Supplimental"; break}
                "rtf"	 {"Supplimental"; break}
                default  {"$_"; break}
            }

            if(($Subfolder -eq 'OT') -or ($Subfolder -eq 'TT')){
                $Subfolder = "$Subfolder $FontFileVersion"
            }

            $Step1 = [IO.Path]::Combine($Subfolder, $FontFileName)

            # Whitespace Cleanup
            # $Step2 = $Step1 -replace '\s+', ' '
            # $Step2 = $Step2.Trim()


            $FinStep = [IO.Path]::Combine($FontDirectory, $PathNoFn, $Subfolder)

            Write-Host "`$FinStep:" $FinStep -ForegroundColor Green

            if(!(Test-Path -LiteralPath $FinStep -PathType Container)){
                [IO.Directory]::CreateDirectory($FinStep)
            }

            $Dest = [IO.Path]::Combine($FinStep, $FontFileName)
            [IO.File]::Move($FontFile, $Dest)

        } -ThrottleLimit $MaxThreads
    }
}