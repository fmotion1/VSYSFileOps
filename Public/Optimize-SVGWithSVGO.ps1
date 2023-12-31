function Optimize-SVGWithSVGO {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        $Files,

        [Parameter(Mandatory=$false)]
        [Switch]
        $ForceRemoveComments,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName)]
        [Int32]
        $MaxThreads = 24
    )

    begin {
        $List = [System.Collections.Generic.List[String]]@()
        & nvm use 21.3.0
    }

    process {
        foreach ($P in $Files) {
            if ($P -is [String]) { $List.Add($P) }
            elseif ($P.Path) { $List.Add($P.Path) }
            elseif ($P.FullName) { $List.Add($P.FullName) }
            elseif ($P.PSPath) { $List.Add($P.PSPath) }
            else { Write-Error "$P is an unsupported type."; throw }
        }
    }

    end {

        $List | ForEach-Object -Parallel {

            $CurrentFile = $_

            [VSYSStructs.FilePathComponents]$Components = Get-FilePathComponents -Path $CurrentFile
            $ActiveFolder = $Components.Folder
            $SVGOConfigFile = Join-Path -Path $ActiveFolder -ChildPath 'svgo.config.js'

            if(Test-Path -LiteralPath $SVGOConfigFile -PathType Leaf){
                $Params = '--config=svgo.config.js', $CurrentFile
            }else{
                if($Using:ForceRemoveComments){
                    $Splat = @{
                        LiteralPath = "D:\Dev\00 Templates\svgo.config\removeCommentsForce\svgo.config.js"
                        Destination = $Components.Folder
                        Force = $true
                    }
                    Copy-Item @Splat | Out-Null
                    $Params = '--config=svgo.config.js', $CurrentFile
                }else{
                    $Params = $CurrentFile
                }
            }

            $CMD = Get-Command svgo.cmd
            & $CMD $Params

        } -ThrottleLimit $MaxThreads
    }
}