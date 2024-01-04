function Convert-CropSVGsInFolderUsingInkscape {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        $Folders,

        [Parameter(Mandatory=$false)]
        [Switch]
        $RenameOutput,

        [Parameter(Mandatory=$false)]
        [Switch]
        $PlaceInSubfolder
    )

    begin {}

    process {

        foreach ($P in $Folders) {
            $Path = if ($P -is [String]) { $P }
                    elseif ($P.Path) { $P.Path }
                    elseif ($P.FullName) { $P.FullName }
                    elseif ($P.PSPath) { $P.PSPath }
                    else { Write-Error "$P is an unsupported type."; throw }

            $AbsolutePath = Resolve-Path -Path $Path

            if (Test-Path -Path $AbsolutePath -PathType Container) {
                $List.Add($AbsolutePath)
            } else {
                Write-Warning "$AbsolutePath does not exist."
                Write-Error "Something went wrong parsing -Folders. Check your input."
                $PSCmdlet.ThrowTerminatingError($PSItem)
            }
        }

        $List | ForEach-Object {

            $CurrentFolder = $_
            $Files = Get-Content -LiteralPath $CurrentFolder -Filter '*.svg'
            Write-Host "`$Files:" $Files -ForegroundColor Green -ForegroundColor White
            #Convert-CropSVGUsingInkscape -


        }
    }
}
