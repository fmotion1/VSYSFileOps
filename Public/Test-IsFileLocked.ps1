Function Test-IsFileLocked {
    [cmdletbinding()]
    Param (
        [parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias('FullName','PSPath','f')]
        [string[]]$File
    )
    Process {
        ForEach ($Item in $File) {
            #Ensure this is a full path
            $Item = Convert-Path $Item
            #Verify that this is a file and not a directory
            If ([System.IO.File]::Exists($Item)) {
                Try {
                    $FileStream = [System.IO.File]::Open($Item,'Open','Write')
                    $FileStream.Close()
                    $FileStream.Dispose()
                    $IsLocked = $False
                } Catch [System.UnauthorizedAccessException] {
                    $IsLocked = 'AccessDenied'
                } Catch {
                    $IsLocked = $True
                }
                [pscustomobject]@{
                    File = $Item
                    IsLocked = $IsLocked
                }
            }
        }
    }
}