using namespace System.IO
function Save-FontsToVersionedFolder {
    [CmdletBinding()]
    param (
        [Alias("f")]
        [Parameter(Mandatory,ValueFromPipeline)]
        $Files,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [Int32]
        $MaxThreads = 16,

        [Parameter(Mandatory=$false)]
        [Switch]
        $WFR
    )

    begin {

        # & "D:\Dev\Python\00 VENV\FontTools\Scripts\Activate.ps1"

        (& "C:\Python\miniconda3\Scripts\conda.exe" "shell.powershell" "hook") | Out-String | ?{$_} | Invoke-Expression
        conda activate FontTools
        $VersionScript = "$env:FONTSCRIPTS\get_font_version.py"

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

            $File  = $_
            $FileC = Get-FilePathComponents -Path $File

            $FileName          = $FileC.FileFullName
            $FileDirectory     = $FileC.ContainingFolder
            $FileExtension     = ($FileC.FileExtension).TrimStart('.')

            if(($FileExtension -eq 'otf') -or ($FileExtension -eq 'ttf')){

                $FontFileVersion = & python $Using:VersionScript $File
                $FontFileVersion = Remove-InvalidFilenameCharacters -Filename $FontFileVersion

                if([string]::IsNullOrWhiteSpace($FontFileVersion)){
                    $FontFileVersion = '1.000'
                }

                if($FontFileVersion -match '^(\d)\.(\d{1,2})$'){
                    $FontFileVersion = $Matches[1] + '.' + $Matches[2] + '0'
                }

                if($FontFileVersion -match '^(\d\.\d{3})(.*)$'){
                    $FontFileVersion = $Matches[1]
                }

                if($FontFileVersion -match '^(0{1,5})(\d*)\.(.*)'){
                    Write-Host "Match" -ForegroundColor White
                    $FontFileVersion = $Matches[2] + '.' + $Matches[3]
                }

                #$FontFileVersion = $FontFileVersion.Substring(0, [Math]::Min(5, $FontFileVersion.Length))
            } else {
                $FontFileVersion = ''
            }

            $OTFolderName = 'OT'
            $TTFolderName = 'TT'
            $WEBFolderName = 'WEB'
            $SupFolderName = "00 Supplimental"
            $LICFolderName = "00 License"

            # Insert the first word occuring in the filename
            # as a prefixed subdirectory

            $Subfolder = switch ($FileExtension) {
                "otf"    {$OTFolderName; break}
                "ttf"    {$TTFolderName; break}
                "svg"	 {"$WEBFolderName"; break}
                "woff2"	 {"$WEBFolderName"; break}
                "woff"	 {"$WEBFolderName"; break}
                "eot"	 {"$WEBFolderName"; break}
                "css"	 {"$WEBFolderName"; break}
                "html"	 {"$WEBFolderName"; break}
                "htm"	 {"$WEBFolderName"; break}
                "ai"	 {"$SupFolderName"; break}
                "md"	 {"$SupFolderName"; break}
                "eps"	 {"$SupFolderName"; break}
                "png"	 {"$SupFolderName"; break}
                "doc"	 {"$SupFolderName"; break}
                "txt"	 {"$SupFolderName"; break}
                "pdf"	 {"$SupFolderName"; break}
                "jpg"	 {"$SupFolderName"; break}
                "jpeg"	 {"$SupFolderName"; break}
                "gif"	 {"$SupFolderName"; break}
                "rtf"	 {"$SupFolderName"; break}
                default  {"$SupFolderName"; break}
            }

            if(($Subfolder -eq 'OT') -or ($Subfolder -eq 'TT')){
                if($Using:WFR){
                    $Subfolder = "$Subfolder $FontFileVersion WFR"
                }else{
                    $Subfolder = "$Subfolder $FontFileVersion"
                }
            }

            Write-Host "`$Subfolder:" $Subfolder -ForegroundColor Green

            if($FileName -like '*LICENSE*'){
                $Subfolder = $LICFolderName
            }

            if(($FileName -match 'UFL.txt') -or ($FileName -match 'OFL.txt')){
                $Subfolder = $LICFolderName
            }

            $FinStep = [IO.Path]::Combine($FileDirectory, $PathNoFn, $Subfolder)

            Write-Host "`$FinStep:" $FinStep -ForegroundColor Green

            if(!(Test-Path -LiteralPath $FinStep -PathType Container)){
                [IO.Directory]::CreateDirectory($FinStep)
            }

            if(($FileExtension -eq 'otf') -or ($FileExtension -eq 'ttf')){
                $Script = "$env:FONTSCRIPTS\get_real_font_name_with_extension.py"
                $RealFontName = & python $Script $FileName

                if(-not[String]::IsNullOrEmpty($RealFontName)){
                    $FileName = $RealFontName
                }
            }


            $FinStep = $FinStep.Trim()
            $Dest = [IO.Path]::Combine($FinStep, $FileName)


            Write-Host "`$File:" $File -ForegroundColor White
            Write-Host "`$Dest:" $Dest -ForegroundColor White

            [IO.File]::Move($File, $Dest)

        } -ThrottleLimit $MaxThreads
    }
}