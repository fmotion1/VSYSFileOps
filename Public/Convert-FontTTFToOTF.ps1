function Convert-FontTTFToOTF {
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

            $Script = "$env:FONTSCRIPTS\fontforge_convert_ttf_to_otf.py"
            $APP = "$env:FONTFORGEBIN\ffpython.exe"
            & $APP $Script $CurrentFile

        } -ThrottleLimit $MaxThreads
    }
}