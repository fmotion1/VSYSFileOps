@{
RootModule = 'VSYSFileOps.psm1'
ModuleVersion = '1.0.0'
GUID = '96f00e2f-7c7c-44ae-b66a-1a5cf00d3655'
Author = 'futur'
Copyright = '(c) futur. All rights reserved.'

# Modules that must be imported into the global environment prior to importing this module
RequiredModules = @('VSYSUtility', 'VSYSGUIOps', 'BurntToast')

# Assemblies that must be loaded prior to importing this module
RequiredAssemblies = @( 'System.Drawing', 'System.Windows.Forms', 'PresentationCore',
                        'PresentationFramework', 'System.Web')

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = @('Convert-ImageToMetadataExiv2', 'Convert-OBJ2VOX', 'Convert-PATToImages', 'Convert-PNGtoICO',
'Convert-RasterToRaster', 'Convert-RecolorPNG', 'Convert-SVGtoICO', 'Convert-SVGToPNGBySize',
'Convert-VectorToRaster', 'Convert-VectorToSVG', 'Convert-WavpackToWav', 'Copy-DirectoryStructureToNewFolder',
'Copy-PathToClipboard', 'Enable-PrivilegeForProcess', 'Get-DefaultBrowser', 'Get-FilePathComponent',
'Get-FilePathComponents', 'Get-SpecialFolderPath', 'Get-SVGsFromFile', 'Get-SVGsFromFileBase64',
'Get-TopMostExplorerWindow', 'Get-UniqueColorsInSVG', 'Group-ImageByColor', 'Group-ImagesBySingleColor',
'Group-SortImagesBySize', 'Group-SortSVGsBySize', 'Group-SortSVGsBySizeInDirectory',
'Convert-iTermColorsToINI', 'Convert-ImageToMetadataIdentify', 'Group-SortSVGsBySizeWidthHeight',
'Group-SplitDirectoryContentsToSubfolders', 'Merge-FlattenDirectory', 'Optimize-SVGWithSVGCleaner',
'Optimize-SVGWithSVGO', 'Register-DLLorOCX', 'Rename-FontToActualName', 'Rename-FontToActualNameDirectory',
'Rename-RandomizeFilenames', 'Request-AdminRights', 'Request-ExplorerRefresh', 'Save-RandomDataToFile',
'Save-RandomDataToFiles', 'Search-GoogleIt', 'Set-FolderIcon', 'Set-SVGOpacityToOpaque', 'Test-FileIsLocked',
'Convert-FontEmbedLevelToUnrestricted', 'Convert-FontGlyphsToSVGsFontForge',
'Convert-FontGlyphsToSVGsFonts2Svg', 'Convert-FontOTFToTTF', 'Convert-FontToSVG',
'Convert-FontToTTXXML', 'Convert-FontTTFToOTF', 'Convert-FontWOFFCompress',
'Convert-FontWOFFCompressGoogle', 'Convert-FontWOFFDecompress', 'Convert-ImageToMetadataAll',
'Convert-ImageToMetadataEXIFTool', 'Remove-NonBreakingSpaceFromFiles', 'Save-FontsToFolderByWord',
'Remove-NonBreakingSpaceFromFilesInList', 'Remove-NBSPFromFile','Save-FontsToVersionedFolder',
'Save-FontsToVersionedFolderMulti','Rename-SeparatePascalCase','Publish-ImageToImgur',
'Publish-ImageToGoogleReverseImageSearch','Get-ImageDominantColors','Get-ImageDominantSingleColor',
'Remove-InvalidFilenameCharacters','Convert-ResizeRasterImage',
'Get-ImageDimensions')

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @()


# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        # Tags = @()

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        # ProjectUri = ''

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        # ReleaseNotes = ''

        # Prerelease string of this module
        # Prerelease = ''

        # Flag to indicate whether the module requires explicit user acceptance for install/update/save
        # RequireLicenseAcceptance = $false

        # External dependent modules of this module
        # ExternalModuleDependencies = @()

    } # End of PSData hashtable

} # End of PrivateData hashtable
}

