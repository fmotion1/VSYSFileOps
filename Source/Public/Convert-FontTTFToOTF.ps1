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
        D:\Dev\Python\FontTools\Scripts\Activate.ps1
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

            $Script = "D:\Dev\Python\FontSripts\ConvertTTFToOTF.py"
            #[void] (& ffpython `"$Script`" `"$CurrentFile`" 2>&1 | Tee-Object -Variable allOutput)
            & fontforge -script $Script $CurrentFile

        } -ThrottleLimit $MaxThreads
    }
}