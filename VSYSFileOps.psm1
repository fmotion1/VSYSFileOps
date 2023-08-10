# Get public and private function definition files..ps1",
#$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue -Recurse )
$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Recurse )

# $Public = @(
#     "$PSScriptRoot\Public\Convert-ImageToMetadataExiv2.ps1",
#     "$PSScriptRoot\Public\Convert-OBJ2VOX.ps1",
#     "$PSScriptRoot\Public\Convert-PATToImages.ps1",
#     "$PSScriptRoot\Public\Convert-PNGtoICONew.ps1",
#     "$PSScriptRoot\Public\Convert-RasterToRaster.ps1",
#     "$PSScriptRoot\Public\Convert-RecolorPNG.ps1",
#     "$PSScriptRoot\Public\Convert-SVGtoICO.ps1",
#     "$PSScriptRoot\Public\Convert-SVGToPNGBySize.ps1",
#     "$PSScriptRoot\Public\Convert-VectorToRaster.ps1",
#     "$PSScriptRoot\Public\Convert-VectorToSVG.ps1",
#     "$PSScriptRoot\Public\Convert-WavpackToWav.ps1",
#     "$PSScriptRoot\Public\Copy-DirectoryStructureToNewFolder.ps1",
#     "$PSScriptRoot\Public\Copy-PathToClipboard.ps1",
#     "$PSScriptRoot\Public\Enable-PrivilegeForProcess.ps1",
#     "$PSScriptRoot\Public\Get-DefaultBrowser.ps1",
#     "$PSScriptRoot\Public\Get-FilePathComponent.ps1",
#     "$PSScriptRoot\Public\Get-FilePathComponents.ps1",
#     "$PSScriptRoot\Public\Get-SpecialFolderPath.ps1",
#     "$PSScriptRoot\Public\Get-SVGsFromFile.ps1",
#     "$PSScriptRoot\Public\Get-SVGsFromFileBase64.ps1",
#     "$PSScriptRoot\Public\Get-TopMostExplorerWindow.ps1",
#     "$PSScriptRoot\Public\Get-UniqueColorsInSVG.ps1",
#     "$PSScriptRoot\Public\Group-ImageByColor.ps1",
#     "$PSScriptRoot\Public\Group-ImagesBySingleColor.ps1",
#     "$PSScriptRoot\Public\Group-SortImagesBySize.ps1",
#     "$PSScriptRoot\Public\Group-SortSVGsBySize.ps1",
#     "$PSScriptRoot\Public\Group-SortSVGsBySizeInDirectory.ps1",
#     "$PSScriptRoot\Public\Convert-iTermColorsToINI.ps1",
#     "$PSScriptRoot\Public\Convert-ImageToMetadataIdentify.ps1",
#     "$PSScriptRoot\Public\Group-SortSVGsBySizeWidthHeight.ps1",
#     "$PSScriptRoot\Public\Group-SplitDirectoryContentsToSubfolders.ps1",
#     "$PSScriptRoot\Public\Merge-FlattenDirectory.ps1",
#     "$PSScriptRoot\Public\Optimize-SVGWithSVGCleaner.ps1",
#     "$PSScriptRoot\Public\Optimize-SVGWithSVGO.ps1",
#     "$PSScriptRoot\Public\Register-DLLorOCX.ps1",
#     "$PSScriptRoot\Public\Rename-FontToActualName.ps1",
#     "$PSScriptRoot\Public\Rename-FontToActualNameDirectory.ps1",
#     "$PSScriptRoot\Public\Rename-RandomizeFilenames.ps1",
#     "$PSScriptRoot\Public\Request-AdminRights.ps1",
#     "$PSScriptRoot\Public\Request-ExplorerRefresh.ps1",
#     "$PSScriptRoot\Public\Save-RandomDataToFile.ps1",
#     "$PSScriptRoot\Public\Save-RandomDataToFiles.ps1",
#     "$PSScriptRoot\Public\Search-GoogleIt.ps1",
#     "$PSScriptRoot\Public\Set-FolderIcon.ps1",
#     "$PSScriptRoot\Public\Set-SVGOpacityToOpaque.ps1",
#     "$PSScriptRoot\Public\Test-IsFileLocked.ps1",
#     "$PSScriptRoot\Public\Convert-FontEmbedLevelToUnrestricted.ps1",
#     "$PSScriptRoot\Public\Convert-FontGlyphsToSVGsFontForge.ps1",
#     "$PSScriptRoot\Public\Convert-FontGlyphsToSVGsFonts2Svg.ps1",
#     "$PSScriptRoot\Public\Convert-FontOTFToTTF.ps1",
#     "$PSScriptRoot\Public\Convert-FontToSVG.ps1",
#     "$PSScriptRoot\Public\Convert-FontToTTXXML.ps1",
#     "$PSScriptRoot\Public\Convert-FontTTFToOTF.ps1",
#     "$PSScriptRoot\Public\Convert-FontWOFFCompress.ps1",
#     "$PSScriptRoot\Public\Convert-FontWOFFCompressGoogle.ps1",
#     "$PSScriptRoot\Public\Convert-FontWOFFDecompress.ps1",
#     "$PSScriptRoot\Public\Convert-ImageToMetadataAll.ps1",
#     "$PSScriptRoot\Public\Convert-ImageToMetadataEXIFTool.ps1"
# )

$FoundErrors = @(
    Foreach ($Import in $Public) {
        Try {
            . $Import.Fullname
        } Catch {
            throw
            #Write-Host "Error: " $_
        }
    }
)

if ($FoundErrors.Count -gt 0) {
    $ModuleName = (Get-ChildItem $PSScriptRoot\*.psm1).BaseName
    Write-Warning "Importing module $ModuleName failed. Fix errors before continuing."
}

Export-ModuleMember -Function   Convert-ImageToMetadataExiv2, Convert-OBJ2VOX, Convert-PATToImages, Convert-PNGtoICO,
                                Convert-RasterToRaster, Convert-RecolorPNG, Convert-SVGtoICO, Convert-SVGToPNGBySize,
                                Convert-VectorToRaster, Convert-VectorToSVG, Convert-WavpackToWav, Copy-DirectoryStructureToNewFolder,
                                Copy-PathToClipboard, Enable-PrivilegeForProcess, Get-DefaultBrowser, Get-FilePathComponent,
                                Get-FilePathComponents, Get-SpecialFolderPath, Get-SVGsFromFile, Get-SVGsFromFileBase64,
                                Get-TopMostExplorerWindow, Get-UniqueColorsInSVG, Group-ImageByColor, Group-ImagesBySingleColor,
                                Group-SortImagesBySize, Group-SortSVGsBySize, Group-SortSVGsBySizeInDirectory,
                                Convert-iTermColorsToINI, Convert-ImageToMetadataIdentify, Group-SortSVGsBySizeWidthHeight,
                                Group-SplitDirectoryContentsToSubfolders, Merge-FlattenDirectory, Optimize-SVGWithSVGCleaner,
                                Optimize-SVGWithSVGO, Register-DLLorOCX, Rename-FontToActualName, Rename-FontToActualNameDirectory,
                                Rename-RandomizeFilenames, Request-AdminRights, Request-ExplorerRefresh, Save-RandomDataToFile,
                                Save-RandomDataToFiles, Search-GoogleIt, Set-FolderIcon, Set-SVGOpacityToOpaque, Test-FileIsLocked,
                                Convert-FontEmbedLevelToUnrestricted, Convert-FontGlyphsToSVGsFontForge,
                                Convert-FontGlyphsToSVGsFonts2Svg, Convert-FontOTFToTTF, Convert-FontToSVG,
                                Convert-FontToTTXXML, Convert-FontTTFToOTF, Convert-FontWOFFCompress,
                                Convert-FontWOFFCompressGoogle, Convert-FontWOFFDecompress, Convert-ImageToMetadataAll,
                                Convert-ImageToMetadataEXIFTool, Remove-NonBreakingSpaceFromFiles, Save-FontsToFolderByWord,
                                Remove-NonBreakingSpaceFromFilesInList, Remove-NBSPFromFile,Save-FontsToFolder,Rename-SeparatePascalCase,
                                Publish-ImageToImgur,Publish-ImageToGoogleReverseImageSearch,Get-ImageDominantColor


