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

            $Script = "D:\Dev\Python\Font Scripts\ReturnRealFontNameAsFile.py"

            $RealFontName = & python $Script $CurrentFile

            # $STDERR = $allOutput | Where-Object { $_ -is [System.Management.Automation.ErrorRecord] }
            # $Filename = Split-Path $CurrentFile -Leaf
            # if($LASTEXITCODE -ne 0){
            #     Write-Error "Error processing $Filename. Exit code is not 0. Real font name couldn't be determined."
            #     return
            # }

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