function Convert-FontWOFFCompressGoogle {
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

            $TempDir = New-TempDirectory
            $TempDirName = $TempDir.FullName

            $CurrentFile = $_.Replace('`[', '[')
            $CurrentFile = $CurrentFile.Replace('`]', ']')

            $CopiedFile = Copy-Item -LiteralPath $CurrentFile -Destination $TempDirName -PassThru

            #[void] (& woff2_compress.exe `"$($CopiedFile.FullName)`" 2>&1 | Tee-Object -Variable allOutput)
            & woff2_compress.exe $($CopiedFile.FullName)

            # $STDERR = $allOutput | Where-Object { $_ -is [System.Management.Automation.ErrorRecord] }
            # $Filename = Split-Path $CurrentFile -Leaf
            # if($LASTEXITCODE -ne 0){
            #     Write-Error "Error processing $Filename. Exit code is not 0."
            #     return
            # }

            $Base = Get-FilePathComponent -Path $CopiedFile.FullName -Component FullPathNoExtension
            $CreatedWOFF = $Base + ".woff2"

            $DestFolder = Get-FilePathComponent -Path $CurrentFile -Component Folder
            $DestFile = [IO.Path]::Combine($DestFolder, (Split-Path $CreatedWOFF -Leaf))

            $Index = 2
            $PadIndexTo = '2'
            $StaticFilename = Get-FilePathComponent $DestFile -Component FullPathNoExtension
            $FileExtension  = Get-FilePathComponent $DestFile -Component FileExtension
            while (Test-Path -LiteralPath $DestFile -PathType Leaf) {
                $DestFile = "{0}_{1:d$PadIndexTo}{2}" -f $StaticFilename, $Index, $FileExtension
                $Index++
            }

            Move-Item -LiteralPath $CreatedWOFF -Destination $DestFile

        } -ThrottleLimit $MaxThreads
    }
}