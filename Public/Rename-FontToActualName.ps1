function Rename-FontToActualName {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        $Files,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [Int32]
        $MaxThreads = 16
    )

    begin {
        & "$env:PYVENV\FontTools\Scripts\Activate.ps1"
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

            $CurrentFile = $_.Replace('`[', '[')
            $CurrentFile = $CurrentFile.Replace('`]', ']')

            $Script = "$env:FONTSCRIPTS\get_real_font_name_with_extension.py"
            $RealFontName = & python $Script $CurrentFile

            $CurFileName = [System.IO.Path]::GetFileName($CurrentFile)
            if($RealFontName -eq $CurFileName){ return }

            $NewFontFull = Join-Path -Path ([System.IO.Path]::GetDirectoryName($CurrentFile)) -ChildPath $RealFontName

            $Index = 2
            $PadIndexTo = '2'
            $StaticFilename = Get-FilePathComponent $NewFontFull -Component FullPathNoExtension
            $FileExtension  = Get-FilePathComponent $NewFontFull -Component FileExtension
            while (Test-Path -LiteralPath $NewFontFull -PathType Leaf) {
                $NewFontFull = "{0}_{1:d$PadIndexTo}{2}" -f $StaticFilename, $Index, $FileExtension
                $Index++
            }

            Rename-Item -LiteralPath $CurrentFile -NewName $NewFontFull -Force

        } -ThrottleLimit $MaxThreads
    }
}