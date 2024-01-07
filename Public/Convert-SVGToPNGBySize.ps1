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

        try {
            $RSVGConvertCMD = Get-Command rsvg-convert.exe
        }
        catch{
            Write-Error "RSVG-Convert is not available in PATH."
            throw $_
        }

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

            $Path = if ($P -is [String])  { $P }
                    elseif ($P.Path)	  { $P.Path }
                    elseif ($P.FullName)  { $P.FullName }
                    elseif ($P.PSPath)	  { $P.PSPath }
                    else { Write-Error "$P is an unsupported type."; throw }

            $AbsolutePath = if ([System.IO.Path]::IsPathRooted($Path)) { $Path } 
            else { Resolve-Path -Path $Path }

            if (Test-Path -Path $AbsolutePath) {
                $List.Add($AbsolutePath)
            } else {
                Write-Warning "$AbsolutePath does not exist."
            }
        }
    }

    end {

        $List | ForEach-Object -Parallel {

            $SVGFileInput = $_
            $SVGFileBase  = [IO.Path]::GetFileNameWithoutExtension($_)
            $TargetSizes  = $Using:Sizes

            $TargetSizes | ForEach-Object {

                $TargetSize = $_
                $DestDirectory = Join-Path -Path (Split-Path -Parent $SVGFileInput) -ChildPath "Conversion $TargetSize"

                if(-not(Test-Path -LiteralPath $DestDirectory -PathType Container)){
                    [IO.Directory]::CreateDirectory($DestDirectory)
                }

                $FinalPNGOutput = Join-Path -Path $DestDirectory -ChildPath ($SVGFileBase + "-" + $TargetSize + '.png')
                & $Using:RSVGConvertCMD -a -w $TargetSize -h $TargetSize -f png $SVGFileInput -o $FinalPNGOutput | Out-Null
            }

        } -ThrottleLimit $MaxThreads
    }
}