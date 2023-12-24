function Group-FontsByWidth {
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [Alias("f","fonts")]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Files
    )

    # Helper function to convert to PascalCase
    $ConvertToPascalCase = {
        param([string]$text)
        # Insert spaces after "Extra" and "Ultra"
        $text = $text -replace '(Extra|Ultra)(Condensed|Compressed|Compact|Narrow|Wide|Extended|Expanded|Slim)', '$1 $2'
        # Insert dash after "Semi"
        $text = $text -replace '(Semi)(Condensed|Compressed|Compact|Narrow|Wide|Extended|Expanded|Slim)', '$1-$2'
        return $text -replace '(^|-| )([a-z])', { $_.Groups[2].Value.ToUpper() }
    }

    # Regex patterns
    $regexPatternA = "(Extra|Ultra|Semi|Ext|Ex|X|XX|XXX|XXXX)( |\-|)(Condensed|Cond|Cnd|Con|Cn|Compressed|Comp|Cmp|Cm|Compact|Narrow|Nar|Wide|Wd|Extended|Extend|Xtnd|Extd|Ext(?!ra)|Expanded|Expand|Xpand|Xpnd|Exp|Slim)"
    $regexPatternB = "(?<=[a-z])(Condensed|Compressed|Compact|Narrow|Wide|Extended|Expanded|Slim|Cond|Cnd|Con|Cn|Comp|Cmp|Extend|Extd|Ext(?!ra))"
    $regexPatternC = "(Condensed|Cond|Cnd|Cn|Compressed|Comp|Cmp|Cm|Compact|Narrow|Wide|Wd|Extended|Extend|Xtnd|Extd|Ext(?!ra)|Expanded|Expand|Xpand|Xpnd|Exp|Slim)"
    
    # Iterate over file paths
    foreach ($fontPath in $Files) {

        # Extract file name from path
        $fileName = [System.IO.Path]::GetFileNameWithoutExtension($fontPath)

        # Initialize a variable to store the matched string
        $matchedString = $null
        $folderName = $null

        # Try matching with the original pattern
        if ($fileName -match $regexPatternA) {
            $matchedString = $matches[0]
            $folderName = & $ConvertToPascalCase -text $matchedString
            # Write-Host "$fileName matched Pattern A" -ForegroundColor White
        }
        # Then, if no match found, try matching with Rule A (case-sensitive)
        elseif ($fileName -cmatch $regexPatternB) {
            $matchedString = $matches[0]
            $folderName = & $ConvertToPascalCase -text $matchedString
            # Write-Host "$fileName matched Pattern B" -ForegroundColor White
        }
        # Finally, if still no match, try matching with Rule B (case-insensitive)
        elseif ($fileName -match $regexPatternC) {
            $matchedString = $matches[0]
            $folderName = & $ConvertToPascalCase -text $matchedString
            # Write-Host "$fileName matched Pattern C" -ForegroundColor White
        }

        # If no regex match, set folder name to "Core"
        if (-not $folderName) {
            $folderName = "Core"
        }

        # Determine the directory and new sub-folder path
        $directory = [System.IO.Path]::GetDirectoryName($fontPath)
        $subFolderPath = Join-Path $directory $folderName

        # Create sub-folder if it doesn't exist
        if (-not (Test-Path $subFolderPath)) {
            New-Item -ItemType Directory -Path $subFolderPath | Out-Null
        }

        # Move file to the new sub-folder
        $newFilePath = Join-Path $subFolderPath ([System.IO.Path]::GetFileName($fontPath))
        Move-Item -Path $fontPath -Destination $newFilePath
    }
}
