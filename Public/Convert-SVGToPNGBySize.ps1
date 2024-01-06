function Convert-SVGToPNGBySize {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        $Files,

        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [String[]] $Sizes,

        [Int32] $MaxThreads = 16
    )

    begin {
        $List = [System.Collections.Generic.List[String]]::new()
        $Sizes | ForEach-Object {
            if($_ -notmatch "^\d{1,4}$"){
                Write-Error "Invalid value passed to Sizes parameter."
                return
            }
        }
    }

    process {
        foreach ($P in $Files) {
            if	   ($P -is [String]) { $List.Add($P) }
            elseif ($P.Path)		 { $List.Add($P.Path) }
            elseif ($P.FullName)	 { $List.Add($P.FullName) }
            elseif ($P.PSPath)	     { $List.Add($P.PSPath) }
            else					 { Write-Warning "$P is an unsupported type." }
        }
    }

    end {

        try {
            $RSVGConvertCMD = Get-Command "$env:bin\rsvg-convert.exe"
        }
        catch{
            throw "rsvg-convert.exe is not in PATH."
        }


        Write-Host "`$Sizes:" $Sizes -ForegroundColor Green

        $List | ForEach-Object -Parallel {

            $SVGFileInput = $_
            $SVGFileBase  = [IO.Path]::GetFileNameWithoutExtension($_)
            $TargetSizes  = $Using:Sizes

            $TargetSizes | ForEach-Object {

                $TargetSize = $_
                $DestDirectory = Join-Path -Path (Split-Path -Parent $SVGFileInput) -ChildPath "Conversion $TargetSize"

                Write-Host "`$DestDirectory:" $DestDirectory -ForegroundColor Green

                if(-not(Test-Path -LiteralPath $DestDirectory -PathType Container)){
                    [IO.Directory]::CreateDirectory($DestDirectory)
                }



                $FinalPNGOutput = Join-Path -Path $DestDirectory -ChildPath ($SVGFileBase + "-" + $TargetSize + '.png')
                Write-Host "`$FinalPNGOutput:" $FinalPNGOutput -ForegroundColor Green
                & $Using:RSVGConvertCMD -a -w $TargetSize -h $TargetSize -f png $SVGFileInput -o $FinalPNGOutput | Out-Null
            }

        } -ThrottleLimit $MaxThreads
    }
}