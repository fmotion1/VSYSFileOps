function Rename-RandomizeFilenames {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        $Files,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [Int32]
        $MaxThreads = 16
    )

    begin {
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
            $CurrentFile = $_
            $RandomStr   = Get-RandomAlphanumericString -Length 20
            $NewFilename = $RandomStr + [System.IO.Path]::GetExtension($CurrentFile)

            Rename-Item -LiteralPath $_ -NewName $NewFilename -Force

        } -ThrottleLimit $MaxThreads
    }
}