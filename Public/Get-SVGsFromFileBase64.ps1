function Get-SVGsFromFileBase64 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String]
        $Source,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]
        $Destination,

        [Parameter(Mandatory=$false)]
        [Switch]
        $DisableSVGCleaning
    )

    process {

        $Destination = $Destination.TrimEnd('\')
        Write-Host "`$Source:" $Source -ForegroundColor Green

        if(!(Test-Path -LiteralPath $Destination)){
            New-Item -Path $Destination -ItemType "Directory" -Force
        }

        $TempDirectory = New-TempDirectory -Length 14
        $TempDirName = $TempDirectory.FullName

        $SVGContent = Get-Content -LiteralPath $Source -Raw
        $SVGInlineMatches = $SVGContent | Select-String -Pattern '<svg\b[^>]*?>[\s\S]*?<\/svg>' -AllMatches
        $SVGBase64Matches = $SVGContent | Select-String -Pattern '\(data:image\/svg\+xml;base64,[a-zA-Z0-9+\/=]+\s*\);' -AllMatches
        $SourceFilenameNoExtension = ([IO.Path]::GetFileNameWithoutExtension($Source))

        $TempFileList = [System.Collections.Generic.List[String]]@()

        foreach ($SVGInlineFile in $SVGInlineMatches.Matches) {
            $RND = Get-RandomAlphanumericString -Length 14
            $FileName  = $SourceFilenameNoExtension + "_" + $RND + '.svg'

            $NewFile = [IO.Path]::Combine($TempDirName, $FileName)
            Add-Content $NewFile $SVGInlineFile.Value -Encoding UTF8 | Out-Null
            $TempFileList.Add($NewFile)
        }

        foreach ($SVGBase64File in $SVGBase64Matches.Matches) {

            $Prefix = '(data:image/svg+xml;base64,'
            $Suffix = ');'

            $B64String = [String]$SVGBase64File
            $B64String = $B64String.TrimStart($Prefix)
            $B64String = $B64String.TrimEnd($Suffix)
            $B64String = $B64String.TrimStart()

            $RND      = Get-RandomAlphanumericString -Length 14
            $Bytes    = [System.Convert]::FromBase64String($B64String)
            $FileName = $SourceFilenameNoExtension + "_" + "Base64_" + $RND + '.svg'
            $NewFile  = [IO.Path]::Combine($TempDirName, $FileName)

            [System.IO.File]::WriteAllBytes($NewFile, $Bytes) | Out-Null
            $TempFileList.Add($NewFile)
        }

        if(!$DisableSVGCleaning){
            $TempFileList | ForEach-Object {

                $CurrentFile = $_
                $PathBase    = Get-FilePathComponent -Path $CurrentFile -Component FullPathNoExtension
                $NewPath     = "$PathBase`_svgcleaner.svg"

                & svgcleaner --allow-bigger-file $CurrentFile $NewPath | Out-Null
            }
        }

        $CleanedSVGList = [System.Collections.Generic.List[String]]@()
        $UncleanSVGList = [System.Collections.Generic.List[String]]@()

        $SVGFilesInTemp = Get-ChildItem $TempDirName -File

        foreach ($F in $SVGFilesInTemp) {
            if(!$DisableSVGCleaning){
                if ($F.FullName -like "*_svgcleaner*") {
                    $CleanedSVGList.Add($F.FullName)
                }
            }else{
                $UncleanSVGList.Add($F.FullName)
            }
        }

        $IDX = 1

        if(!$DisableSVGCleaning){
            foreach ($CleanFile in $CleanedSVGList) {

                $SrcFilePath = $CleanFile

                if ($SrcFilePath -like "*_Base64_*") {
                    $DestFileName = "{0}_{1:d3}_Base64_Cleaned.svg" -f $SourceFilenameNoExtension, $IDX
                }else{
                    $DestFileName = "{0}_{1:d3}_Inline_Cleaned.svg" -f $SourceFilenameNoExtension, $IDX
                }

                $IDX++
                $DestFilePath = Join-Path $Destination $DestFileName
                [IO.File]::Move($SrcFilePath,$DestFilePath)
            }
        }else{
            foreach ($UncleanFile in $UncleanSVGList) {

                $SrcFilePath = $UncleanFile

                if ($SrcFilePath -like "*_Base64_*") {
                    $DestFileName = "{0}_{1:d3}_Base64.svg" -f $SourceFilenameNoExtension, $IDX
                }else{
                    $DestFileName = "{0}_{1:d3}_Inline.svg" -f $SourceFilenameNoExtension, $IDX
                }

                $IDX++
                $DestFilePath = Join-Path $Destination $DestFileName
                [IO.File]::Move($SrcFilePath,$DestFilePath)

            }
        }
    }
}