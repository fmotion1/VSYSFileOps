function Optimize-SVGWithSVGOInDirectory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        $Folders,
        [Int32] $MaxThreads = 24
    )

    begin {

        $NVMIsAvailable    = $true
        $LatestNodeSuccess = $true

        try {
            $NVMCmd = Get-Command nvm.exe -CommandType Application -ErrorAction Continue
        } catch {
            Write-Error "NVM is not installed or available."
            $NVMIsAvailable = $false
        }

        if($NVMIsAvailable){
            try {
                $LatestNodeVersion = Get-LatestNodeWithNVM -ErrorAction Continue
            } catch {
                Write-Error "Couldn't get latest node version with NVM."
                $LatestNodeSuccess = $false
            }
        }

        if($NVMIsAvailable -and $LatestNodeSuccess){
            & $NVMCmd use $LatestNodeVersion
        }

        try {
            $SVGOCmd = Get-Command svgo.cmd -ErrorAction Stop
        } catch {
            throw "Fatal: SVGO isn't available in PATH or installed on this machine."
        }

        $List = [System.Collections.Generic.List[string]]@()
    }

    process {

        foreach ($P in $Folders) {

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

            $OptimizeFolder = $_
            $Params = @()
            
            $ConfigFile = Join-Path -Path $OptimizeFolder -ChildPath 'svgo.config.js'
            if (Test-Path -LiteralPath $ConfigFile -PathType Leaf) {
                $Params += '--config=svgo.config.js'
            }

            $Params += '-r', '-f', $OptimizeFolder
            & $Using:SVGOCmd $Params

        } -ThrottleLimit $MaxThreads
    }
}