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

        try {
        
            & "$env:PYVENV\FontTools\Scripts\Activate.ps1"
            $List = [System.Collections.Generic.List[String]]@()
        
        } catch {
        
            $PSCmdlet.ThrowTerminatingError($PSItem)
        
        }
    }

    process {
        
        try {
            foreach ($P in $Files) {
                if ($P -is [String]) { $List.Add($P) }
                elseif ($P.Path)     { $List.Add($P.Path) }
                elseif ($P.FullName) { $List.Add($P.FullName) }
                elseif ($P.PSPath)   { $List.Add($P.PSPath) }
                else { Write-Error "Invalid argument passed to files parameter." }
            }
        } catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }

    end {

        try {
            $List | ForEach-Object -Parallel {

                $File = $_
    
                $FileName = [System.IO.Path]::GetFileName($File)
                $FileDirectory = [System.IO.Directory]::GetParent($File)
                $FileExtension = [System.IO.Path]::GetExtension($File).TrimStart('.')
    
                # Write-Host "`$Versioned:" $Versioned -ForegroundColor Green

                if ($Using:Versioned) {

                    if (($FileExtension -eq 'otf') -or ($FileExtension -eq 'ttf')) {
    
                        $FontFileVersion = & python "$env:FONTSCRIPTS\get_font_version.py" $File
                        
                        # Write-Host "`$FontFileVersion Before:" $FontFileVersion -ForegroundColor Green

                        $invalidChars = [IO.Path]::GetInvalidFileNameChars() -join ''
                        $re = "[{0}]" -f [RegEx]::Escape($invalidChars)
                        $FontFileVersion = $FontFileVersion -replace $re
    
                        if ($FontFileVersion -match '^(0.)(.*)$') {
                            $FontFileVersion = ''
                            # Write-Host "`$FontFileVersion 0:" $FontFileVersion -ForegroundColor Green
                        }
    
                        if ($FontFileVersion -match '^(version\s)(.*)$') {
                            $FontFileVersion = $Matches[2]
                            # Write-Host "`$FontFileVersion 1:" $FontFileVersion -ForegroundColor Green
                        }
    
                        if ([string]::IsNullOrWhiteSpace($FontFileVersion)) {
                            $FontFileVersion = ''
                            # Write-Host "`$FontFileVersion 2:" $FontFileVersion -ForegroundColor Green

                        }
    
                        if ($FontFileVersion -match '^(\d)\.(\d{1,2})$') {
                            $FontFileVersion = $Matches[1] + '.' + $Matches[2] + '0'
                            # Write-Host "`$FontFileVersion 3:" $FontFileVersion -ForegroundColor Green

                        }
    
                        if ($FontFileVersion -match '^(\d\.\d{3})(.*)$') {
                            $FontFileVersion = $Matches[1]
                            # Write-Host "`$FontFileVersion 4:" $FontFileVersion -ForegroundColor Green

                        }
    
                        if ($FontFileVersion -match '^(0{1,5})(\d*)\.(.*)') {
                            $FontFileVersion = $Matches[2] + '.' + $Matches[3]
                            # Write-Host "`$FontFileVersion 5:" $FontFileVersion -ForegroundColor Green

                        }

                        # Write-Host "`$FontFileVersion After: " $FontFileVersion -ForegroundColor Green
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
        } catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)    
        }
    }      
}