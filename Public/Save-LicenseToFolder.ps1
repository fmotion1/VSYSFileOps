function Save-LicenseToFolder {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        $Folder,
    
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [ValidateSet(   'GNU AGPLv3','GNU GPLv3','GNU LGPLv3',
                        'Mozilla Public 2.0','Apache 2.0',
                        'Boost License 1.0','The Unlicense',
                        'MIT','MIT No Attribution', IgnoreCase = $true)]
        [String]
        $LicenseType,
    
        [Parameter(Mandatory=$false)]
        [Switch]
        $Force
    )
    
    begin {
        switch ($LicenseType) {
            "MIT"                 {$LicensePath = "D:\Dev\00 Templates\Licenses\MIT\LICENSE"}
            "MIT No Attribution"  {$LicensePath = "D:\Dev\00 Templates\Licenses\MIT No Attribution\LICENSE"}
            "GNU AGPLv3"          {$LicensePath = "D:\Dev\00 Templates\Licenses\GNU AGPL v3.0\LICENSE"}
            "GNU GPLv3"           {$LicensePath = "D:\Dev\00 Templates\Licenses\GNU GPL v3.0\LICENSE"}
            "GNU LGPLv3"	      {$LicensePath = "D:\Dev\00 Templates\Licenses\GNU GPL v3.0\LICENSE"}
            "Mozilla Public 2.0"  {$LicensePath = "D:\Dev\00 Templates\Licenses\Mozilla Public License 2.0\LICENSE"}
            "Apache 2.0"	      {$LicensePath = "D:\Dev\00 Templates\Licenses\Apache License 2.0\LICENSE"}
            "Boost License 1.0"	  {$LicensePath = "D:\Dev\00 Templates\Licenses\Boost Software License 1.0\LICENSE"}
            "The Unlicense"	      {$LicensePath = "D:\Dev\00 Templates\Licenses\The Unlicense\LICENSE"}
        }
    }
    
    process {
        if($Force){
            Copy-Item $LicensePath -Destination $Folder -Force
        } else {
            $TestCurrent = Join-Path $Folder 'LICENSE'
            if(!(Test-Path -LiteralPath $TestCurrent -PathType Leaf)){
                Copy-Item $LicensePath -Destination $Folder -Force
            }
        }
    }
}
