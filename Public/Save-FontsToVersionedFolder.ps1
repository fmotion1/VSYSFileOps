function Save-FontsToVersionedFolder {
    [CmdletBinding()]
    param (
        [Alias("f")]
        [Parameter(Mandatory, ValueFromPipeline)]
        $Files,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName)]
        [Int32]
        $MaxThreads = 16,

        [Parameter(Mandatory = $false)]
        [Switch]
        $Versioned,

        [Parameter(Mandatory = $false)]
        [Switch]
        $WFR
    )

    begin {

        & "$env:PYVENV\FontTools\Scripts\Activate.ps1"
        $List = @()
    }

    process {
        foreach ($P in $Files) {
            if ($P -is [String]) { $List += $P }
            elseif ($P.Path) { $List += $P.Path }
            elseif ($P.FullName) { $List += $P.FullName }
            elseif ($P.PSPath) { $List += $P.PSPath }
            else { Write-Warning "$P is an unsupported type." }
        }
    }

    end {

        $List | ForEach-Object -Parallel {

            $File = $_

            $FileName = [System.IO.Path]::GetFileName($File)
            $FileDirectory = [System.IO.Directory]::GetParent($File)
            $FileExtension = [System.IO.Path]::GetExtension($File).TrimStart('.')



            if ($Versioned) {
                if (($FileExtension -eq 'otf') -or ($FileExtension -eq 'ttf')) {

                    $FontFileVersion = & python "$env:FONTSCRIPTS\get_font_version.py" $File

                    $invalidChars = [IO.Path]::GetInvalidFileNameChars() -join ''
                    $re = "[{0}]" -f [RegEx]::Escape($invalidChars)
                    $FontFileVersion = $FontFileVersion -replace $re


                    if ([string]::IsNullOrWhiteSpace($FontFileVersion)) {
                        $FontFileVersion = '1.000'
                    }

                    if ($FontFileVersion -match '^(\d)\.(\d{1,2})$') {
                        $FontFileVersion = $Matches[1] + '.' + $Matches[2] + '0'
                    }

                    if ($FontFileVersion -match '^(\d\.\d{3})(.*)$') {
                        $FontFileVersion = $Matches[1]
                    }

                    if ($FontFileVersion -match '^(0{1,5})(\d*)\.(.*)') {
                        Write-Host "Match" -ForegroundColor White
                        $FontFileVersion = $Matches[2] + '.' + $Matches[3]
                    }

                } else {
                    $FontFileVersion = ''
                }
            }

            $WebExtensions = "svg", "woff2", "woff", "eot", "css", "html", "htm"
            $SupExtensions = "ai", "md", "eps", "png", "doc", "txt", "pdf", "jpg", "jpeg", "gif", "rtf"

            $Subfolder = switch ($FileExtension) {
                "otf" { 'OT'; break }
                "ttf" { 'TT'; break }
                { $WebExtensions -contains $_ } { 'WEB'; break }
                { $SupExtensions -contains $_ } { '00 Supplimental'; break }
                default { '00 Supplimental'; break }
            }

            $WFRString = ($Using:WFR) ? 'WFR' : ''
            if ($Subfolder -in @('OT', 'TT')) {
                $Subfolder = '{0} {1} {2}' -f $Subfolder, $FontFileVersion, $WFRString
                $Subfolder = $Subfolder.Trim()
            }

            if ($FileName -like '*LICENSE*') { $Subfolder = '00 License' }
            if ($FileName -in @('UFL.txt', 'OFL.txt')) { $Subfolder = '00 License' }

            $DestDir = [IO.Path]::Combine($FileDirectory, $Subfolder)

            if (!(Test-Path -LiteralPath $DestDir -PathType Container)) {
                [IO.Directory]::CreateDirectory($DestDir) | Out-Null
            }

            $DestDir = $DestDir.Trim()

            [IO.File]::Move($File, [IO.Path]::Combine($DestDir, $FileName))

        } -ThrottleLimit $MaxThreads
    }
}