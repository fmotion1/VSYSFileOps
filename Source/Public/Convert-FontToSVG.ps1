function Convert-FontToSVG {
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

        #"C:\Program Files (x86)\FontForgeBuilds\fontforge-console.bat"
        #Write-Host "`$List:" $List -ForegroundColor Green
        $List | ForEach-Object -Parallel {


            #Write-Host "Test"

            $CurrentFile = $_.Replace('`[', '[')
            $CurrentFile = $CurrentFile.Replace('`]', ']')

            $Script = "D:\Dev\Python\FontSripts\ConvertTTFToSVG.py"

            & ffpython $Script $CurrentFile
            # & fontforge -script $Script $CurrentFile

            # $STDERR = $allOutput | Where-Object { $_ -is [System.Management.Automation.ErrorRecord] }
            # if($LASTEXITCODE -ne 0){
            #     Write-Error "Error processing $CurrentFile. Exit code is not 0."
            # }
        } -ThrottleLimit $MaxThreads
    }
}