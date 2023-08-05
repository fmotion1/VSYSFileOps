using namespace System.IO
function Save-FontsToFolderByWord {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        $Files,

        [Parameter(Mandatory=$false)]
        [Int32]
        $NumWords = 1,

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

            $FontFile = $_
            $FontFileC = Get-FilePathComponents -Path $FontFile

            $FontFileName      = $FontFileC.FileFullName
            $FontDirectory     = $FontFileC.ContainingFolder
            $FontExtension     = $FontFileC.FileExtension
            $FontFullPathNoExt = $FontFileC.FullPathNoExtension

            $FontFileVersion = & python $Using:VersionScript $FontFile

            Write-Host "`$Using:NumWords:" $Using:NumWords -ForegroundColor Green

            if($Using:NumWords -eq 1){
                $RegExWord = '^(\w+)\b'
                $RegExReplace = '$1\$0'
            }

            if($Using:NumWords -eq 2){
                $RegExWord = '^(\w+)[\s|\-](\w+)\b'
                $RegExReplace = '$1 $2\$0'
            }

            if($Using:NumWords -eq 3){
                $RegExWord = '^(\w+)[\s|\-](\w+)[\s|\-](\w+)\b'
                $RegExReplace = '$1 $2 $3\$0'
            }


            # Insert the first word occuring in the filename
            # as a prefixed subdirectory
            $Step1 = $FontFileName
            $Step2 = $Step1 -replace $RegExWord, $RegExReplace

            # Remove everything after the first '\' Leaving
            # Just the first word.
            $parts = $Step2 -split '\\'
            $Step3 = $parts[0]

            # Whitespace Cleanup
            $Step4 = $Step3 -replace '\s+', ' '
            $Step4 = $Step4.Trim()

            # Camel Case Conversion
            #$Step5 = $Step4 -csplit '(?=[A-Z])' -ne '' -join ' '
            #$Step5 = $Step4 -csplit '([a-z])([A-Z]\S)' -join ' '
            $Step5 = $Step4 -csplit '(?<=[a-z])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])', -join ' '
            #$Step5 = $Step4
            Write-Host "`$Step5:" $Step5 -ForegroundColor Green

            # Edge Case, Rename "Screen Smart" fonts correctly.
            $Step6 = $Step5 -replace ' S Sm', ' SSm'

            $FontExt = [IO.Path]::GetExtension($FontFile)
            if($FontExt -eq '.ttf'){
                $NextPathPart = 'TT'
            }elseif($FontExt -eq '.otf'){
                $NextPathPart = 'OT'
            }else{
                if ( $FontExt -match ".eot" -or
                     $FontExt -match ".svg" -or
                     $FontExt -match ".css" -or
                     $FontExt -match ".woff" -or
                     $FontExt -match ".woff2" -or
                     $FontExt -match ".html" ){
                        $NextPathPart = 'WEB'
                     }
            }

            $PathNoFn = "$FontDirectory\$Step6\$NextPathPart $FontFileVersion\"
            if(!(Test-Path -LiteralPath $PathNoFn -PathType Container)){
                #Write-Host "`$PathNoFn:" $PathNoFn -ForegroundColor Green
                [IO.Directory]::CreateDirectory($PathNoFn)
                # New-Item -Path $PathNoFn -ItemType Directory -Force
            }

            $FinStep = [IO.Path]::Combine($PathNoFn, $FontFileName)
            [IO.File]::Move($FontFile, $FinStep)

        } -ThrottleLimit $MaxThreads
    }
}