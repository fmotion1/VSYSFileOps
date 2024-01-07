function Optimize-SVGWithSVGO {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        $Files,
        [Int32] $MaxThreads = 16
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

        $List = [System.Collections.Generic.List[String]]@()
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

        $RND = Get-RandomAlphanumericString -Length 16
        $List | ForEach-Object {

            $CurrentFile = $_
            $CurrentFileDir = [System.IO.Directory]::GetParent($CurrentFile)
            $TempPath = Join-Path $CurrentFileDir -ChildPath $RND
            if(-not($TempPath | Test-Path -PathType Container)){
                New-Item $TempPath -ItemType Directory | Out-Null
            }

            Move-Item -LiteralPath $CurrentFile -Destination $TempPath -Force

        }

        $OptimizeFolder = $TempPath
        $Params = @()
        $Params += '-r', '-f', $OptimizeFolder
        & $SVGOCmd $Params


        $Files = (Get-ChildItem -LiteralPath $TempPath -File -Recurse).FullName
        $Files | ForEach-Object {
            $File = $_
            Move-Item $File -Destination $CurrentFileDir -Force | Out-Null
        }

        Remove-Item $TempPath -Recurse
        
    }
}