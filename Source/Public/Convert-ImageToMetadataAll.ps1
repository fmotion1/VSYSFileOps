function Convert-ImageToMetadataAll {
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

            $DestFile = (Get-FilePathComponent -Path $CurrentFile -Component FullPathNoExtension)+" AllMetadata.txt"

            $IDX = 2
            $PadIndexTo = '2'
            $StaticFilename = Get-FilePathComponent $DestFile -Component FullPathNoExtension
            $FileExtension  = Get-FilePathComponent $DestFile -Component FileExtension
            while (Test-Path -LiteralPath $DestFile -PathType Leaf) {
                $DestFile = "{0} {1:d$PadIndexTo}{2}" -f $StaticFilename, $IDX, $FileExtension
                $IDX++
            }

            $OutputEXIFTool =  (& exiftool -a -G1 -s $CurrentFile 2>&1) -join [Environment]::NewLine
            $OutputID       =  (& identify -verbose $CurrentFile 2>&1)  -join [Environment]::NewLine
            $OutputExiv2    =  (& exiv2 -pa $CurrentFile 2>&1)          -join [Environment]::NewLine

            "ImageMagick Identify: $([Environment]::NewLine)" | Out-File $DestFile -Encoding utf8
            $OutputID                                         | Out-File $DestFile -Encoding utf8 -Append
            [Environment]::NewLine                            | Out-File $DestFile -Encoding utf8 -Append
            "EXIFTool:"                                       | Out-File $DestFile -Encoding utf8 -Append
            [Environment]::NewLine                            | Out-File $DestFile -Encoding utf8 -Append
            $OutputEXIFTool                                   | Out-File $DestFile -Encoding utf8 -Append
            [Environment]::NewLine                            | Out-File $DestFile -Encoding utf8 -Append
            "exiv2:"                                          | Out-File $DestFile -Encoding utf8 -Append
            [Environment]::NewLine                            | Out-File $DestFile -Encoding utf8 -Append
            $OutputExiv2                                      | Out-File $DestFile -Encoding utf8 -Append

        } -ThrottleLimit $MaxThreads
    }
}