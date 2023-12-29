# Define the regular expression outside of the function
$invalidChars = [IO.Path]::GetInvalidFileNameChars() -join ''
$invalidFileNameCharsRegex = "[{0}]" -f [RegEx]::Escape($invalidChars)

Function Remove-InvalidFilenameCharacters {
    param(
      [Parameter(Mandatory=$true,
        Position=0,
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
      [String]$Name
    )
  
    # Use the pre-defined regular expression to replace invalid characters
    return ($Name -replace $invalidFileNameCharsRegex)
}