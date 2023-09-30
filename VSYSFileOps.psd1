@{
    RootModule = 'VSYSFileOps.psm1'
    ModuleVersion = '1.0.0'
    GUID = '96f00e2f-7c7c-44ae-b66a-1a5cf00d3655'
    Author = 'futur'
    CompanyName = 'Futuremotion'
    Copyright = '(c) Futuremotion. All rights reserved.'

    CompatiblePSEditions = @('Core')

    Description = 'Provides functions related to working with files and paths.'
    PowerShellVersion = '7.0'

    CmdletsToExport = @()
    VariablesToExport = '*'
    AliasesToExport = @()
    ScriptsToProcess = @()
    TypesToProcess = @()
    FormatsToProcess = @()
    FileList = @()

    # Leave commented out to import into any host.
    # PowerShellHostName = ''

    RequiredModules =    'VSYSUtility', 
                         'VSYSGUIOps', 
                         'BurntToast'

    RequiredAssemblies = 'System.Drawing', 
                         'System.Windows.Forms', 
                         'PresentationCore', 
                         'PresentationFramework', 
                         'System.Web'

    FunctionsToExport =  'Convert-ImageToMetadataExiv2',
                         'Convert-OBJ2VOX',
                         'Convert-PATToImages',
                         'Convert-PNGtoICO',
                         'Convert-RasterToRaster',
                         'Convert-RecolorPNG',
                         'Convert-SVGtoICO',
                         'Convert-SVGToPNGBySize',
                         'Convert-VectorToRaster',
                         'Convert-VectorToSVG',
                         'Convert-WavpackToWav',
                         'Copy-DirectoryStructureToNewFolder',
                         'Copy-PathToClipboard',
                         'Get-DefaultBrowser',
                         'Get-FilePathComponent',
                         'Get-FilePathComponents',
                         'Get-SpecialFolderPath',
                         'Get-SVGsFromFile',
                         'Get-SVGsFromFileBase64',
                         'Get-TopMostExplorerWindow',
                         'Get-UniqueColorsInSVG',
                         'Group-ImageByColor',
                         'Group-ImagesBySingleColor',
                         'Group-SortImagesBySize',
                         'Group-SortSVGsBySize',
                         'Group-SortSVGsBySizeInDirectory',
                         'Convert-iTermColorsToINI',
                         'Convert-ImageToMetadataIdentify',
                         'Group-SortSVGsBySizeWidthHeight',
                         'Group-SplitDirectoryContentsToSubfolders',
                         'Merge-FlattenDirectory',
                         'Optimize-SVGWithSVGCleaner',
                         'Optimize-SVGWithSVGO',
                         'Register-DLLorOCX',
                         'Rename-FontToActualName',
                         'Rename-FontToActualNameDirectory',
                         'Rename-RandomizeFilenames',
                         'Request-AdminRights',
                         'Request-ExplorerRefresh',
                         'Save-RandomDataToFile',
                         'Save-RandomDataToFiles',
                         'Search-GoogleIt',
                         'Set-FolderIcon',
                         'Set-SVGOpacityToOpaque',
                         'Test-FileIsLocked',
                         'Convert-FontEmbedLevelToUnrestricted',
                         'Convert-FontGlyphsToSVGsFontForge',
                         'Convert-FontGlyphsToSVGsFonts2Svg',
                         'Convert-FontOTFToTTF',
                         'Convert-FontToSVG',
                         'Convert-FontToTTXXML',
                         'Convert-FontTTFToOTF',
                         'Convert-FontWOFFCompress',
                         'Convert-FontWOFFCompressGoogle',
                         'Convert-FontWOFFDecompress',
                         'Convert-ImageToMetadataAll',
                         'Convert-ImageToMetadataEXIFTool',
                         'Remove-NonBreakingSpaceFromFiles',
                         'Save-FontsToFolderByWord',
                         'Remove-NonBreakingSpaceFromFilesInList',
                         'Remove-NBSPFromFile',
                         'Save-FontsToVersionedFolder',
                         'Save-FontsToVersionedFolderMulti',
                         'Rename-SeparatePascalCase',
                         'Publish-ImageToImgur',
                         'Publish-ImageToGoogleReverseImageSearch',
                         'Get-ImageDominantColors',
                         'Get-ImageDominantSingleColor',
                         'Remove-InvalidFilenameCharacters',
                         'Convert-ResizeRasterImage',
                         'Convert-SVGCrop',
                         'Get-ImageDimensions',
                         'Convert-SVGToPNGBySizeInFolder',
                         'Rename-FilesInFolder',
                         'Optimize-SVGWithSVGOInDirectory',
                         'Save-LicenseToFolder'

    PrivateData = @{
        PSData = @{
            Tags = @('Automation', 'File', 'Path', 'Rename', 'Convert', 'Windows', "Directory")
            LicenseUri = 'https://github.com/fmotion1/VSYSFileOps/blob/main/LICENSE'
            ProjectUri = 'https://github.com/fmotion1/VSYSFileOps'
            IconUri = 'https://raw.githubusercontent.com/fmotion1/VSYSFileOps/main/Img/FileOpsIconUri.png'
            ReleaseNotes = '1.0.0: (09-29-2023) - Initial Release'
        }
    }
}

