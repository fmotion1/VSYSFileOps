<#
.SYNOPSIS
    Copies paths or filenames to the clipboard.

.DESCRIPTION
    This function will copy both file and folder paths, and optionally
    just filenames. This seems like a simple task, but there are
    a couple enhancements that have been added that set this implementation
    apart from the usual.

    1. All copied paths will be sorted in a human friendly numerical order
    if they contain numbers or sequences of numbers.

    2. Both files and folders will be sorted alphabetically. If both folders
    and files are passed in to copy, folders will always appear before files.
    No matter what, both will be sorted properly.

    3. This function is designed to be called from the right click context
    menu in Windows explorer. It performs much better than the included
    "Copy as Path" function that ships with Windows.

.PARAMETER Path
    A single path or array of paths to copy.

.PARAMETER FilenamesOnly
    Limits the copy to file names and folder names only.

.PARAMETER SurroundQuotes
    Determines whether the copied text will be surrounded by double quotes.

.EXAMPLE
    Copy-PathToClipboard -Path $ArrayOfFilesAndFolders -SurroundQuotes

.INPUTS
    A single string or array of strings representing file/folder paths.

.OUTPUTS
    Nothing. The clipboard will be populated with data.

.NOTES
    Name: Copy-PathToClipboard
    Author: Visusys
    Release: 1.0.0
    License: MIT License
    DateCreated: 2021-12-04

.LINK
    https://github.com/visusys

#>

function Copy-PathToClipboard {
    param(
        [string[]]$Path,
        [switch]$FilenamesOnly,
        [switch]$NoQuotes,
        [switch]$NoExtension,
        [switch]$AsArray
    )

    # Check for incompatible switch combination
    if ($AsArray -and $NoQuotes) {
        throw "The AsArray and NoQuotes switches cannot be used together."
    }

    # Separate files and folders for individual processing
    $files = @()
    $folders = @()

    foreach ($item in $Path) {
        if (Test-Path $item -PathType Leaf) {
            $files += $item
        } elseif (Test-Path $item -PathType Container) {
            $folders += $item
        }
    }

    # Define a helper function to process paths
    function Process-Path {
        param(
            [string]$Path,
            [bool]$IsFile
        )

        $fileName = [System.IO.Path]::GetFileName($Path)
        $extension = [System.IO.Path]::GetExtension($Path)
        $directory = [System.IO.Path]::GetDirectoryName($Path)

        # Extract filename or folder name if required
        if ($FilenamesOnly) {
            if ($IsFile -and -not $NoExtension) {
                # Keep the extension for files when $NoExtension is not set
                $Path = $fileName
            } else {
                # Remove extension if $NoExtension is set or item is a folder
                $Path = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
            }
        } elseif ($NoExtension -and $IsFile) {
            # Remove extension from files if required
            $Path = [System.IO.Path]::Combine($directory, [System.IO.Path]::GetFileNameWithoutExtension($fileName))
        }

        # Add quotes if required and not outputting as an array
        if (-not $NoQuotes -and -not $AsArray) {
            $Path = "`"$Path`""
        }

        return $Path
    }

    # Process files and folders
    $processedFiles = $files | ForEach-Object { Process-Path -Path $_ -IsFile $true }
    $processedFolders = $folders | ForEach-Object { Process-Path -Path $_ -IsFile $false }

    # Sort files and folders numerically
    $sortedFiles = $processedFiles | Format-SortNumerical
    $sortedFolders = $processedFolders | Format-SortNumerical

    # Combine sorted folders and files
    $combinedPaths = $sortedFolders + $sortedFiles

    # Format as a PowerShell array if required
    if ($AsArray) {
        $formattedArray = "`$OutputArray = @(`n"
        foreach ($path in $combinedPaths) {
            $formattedArray += "    `"$path`",`n"
        }
        $formattedArray = $formattedArray.TrimEnd(",`n")  # Remove the last comma
        $formattedArray += "`n)"

        # Set the formatted array to the clipboard
        $formattedArray | Set-Clipboard
    } else {
        # Clear the clipboard before setting the new content
        [System.Windows.Forms.Clipboard]::Clear()

        # Copy the combined, processed paths to the clipboard
        $combinedPaths | Set-Clipboard
    }
}


# Example usage:
# Copy-PathToClipboard -Path @("C:\path\to\file1.txt", "C:\path\to\folder1") -FilenamesOnly -AsArray

