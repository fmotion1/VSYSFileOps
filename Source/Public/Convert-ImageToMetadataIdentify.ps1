function Convert-ImageToMetadataIdentify {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        $Files,

        [Parameter(Mandatory=$false)]
        [Switch]
        $SaveToFile,

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

            if($SaveToFile){
                $CurrentFile = $_
                $DestFile = (Get-FilePathComponent -Path $CurrentFile -Component FullPathNoExtension)+" Identify.txt"

                $IDX = 2
                $PadIndexTo = '2'
                $StaticFilename = Get-FilePathComponent $DestFile -Component FullPathNoExtension
                $FileExtension  = Get-FilePathComponent $DestFile -Component FileExtension
                while (Test-Path -LiteralPath $DestFile -PathType Leaf) {
                    $DestFile = "{0} {1:d$PadIndexTo}{2}" -f $StaticFilename, $IDX, $FileExtension
                    $IDX++
                }

                & identify -verbose $CurrentFile 2>&1 | Out-File $DestFile -Encoding utf8

            } else{
                & identify -verbose $_
            }


        } -ThrottleLimit $MaxThreads
    }
}