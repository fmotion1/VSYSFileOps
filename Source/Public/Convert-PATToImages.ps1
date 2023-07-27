function Convert-PATToImages {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        $Files,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName)]
        [Switch]
        $RenameToFilename,

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

            $ImagesDir  = Get-FilePathComponent -Path $_ -Component FullPathNoExtension
            $InputFile  = $_

            $IDX = 2
            $PadIndexTo = '1'
            $StaticFilename = $ImagesDir
            while (Test-Path -LiteralPath $ImagesDir -PathType Container) {
                $ImagesDir = "{0} {1:d$PadIndexTo}" -f $StaticFilename, $IDX
                $IDX++
            }

            New-Item -Path $ImagesDir -ItemType Directory -Force
            $ImagesDir = $ImagesDir + '\\'

            $RenameStr = ($RenameToFilename) ? 'true' : 'false'

            $Script = "C:\BIN\Node\Pat2Image\save.js"
            [void] (& node.exe `"$Script`" `"$InputFile`" `"$ImagesDir`" `"$RenameStr`" 2>&1 | Tee-Object -Variable allOutput)

            $STDERR = $allOutput | Where-Object { $_ -is [System.Management.Automation.ErrorRecord] }
            $Filename = Split-Path $InputFile -Leaf
            if($LASTEXITCODE -ne 0){
                Write-Error "Error processing $Filename. Exit code is not 0."
            }

        } -ThrottleLimit $MaxThreads
    }
}