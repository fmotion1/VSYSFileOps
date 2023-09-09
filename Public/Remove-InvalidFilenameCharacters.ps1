Function Remove-InvalidFilenameCharacters {
    param(
        [Alias("f")]
        [Parameter( Mandatory,Position=0,
                    ValueFromPipeline,
                    ValueFromPipelineByPropertyName)]
        [String]
        $Filename
    )

    $invalidChars = [IO.Path]::GetInvalidFileNameChars() -join ''
    $re = "[{0}]" -f [RegEx]::Escape($invalidChars)
    return ($Filename -replace $re)
}