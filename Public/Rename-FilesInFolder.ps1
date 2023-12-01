function Rename-FilesInFolder {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $Folders,

        [Parameter(Mandatory)]
        [String]
        $PresetName
    )

    $Folders | ForEach-Object {

        $Folder = $_
        $TempDirectory = New-TempDirectory -Length 16
        [array]$Files = (Get-ChildItem -LiteralPath $Folder -Recurse).FullName
        Write-Host "`$Files.GetType():" $Files.GetType() -ForegroundColor Green
        Write-Host "`$Files.GetType().Name:" $Files.GetType().Name -ForegroundColor Green
        Write-Host "`$Files.GetType().BaseType:" $Files.GetType().BaseType -ForegroundColor Green
        [int]$FileCounter = 0
        [int]$AbsoluteFileCounter = 1
        [int]$TextFileCounter = 1
        [int]$MaxFilenamesPerFile = 1000
        $FileListsArr = @()

        $TextFilePath = Join-Path $TempDirectory ("FileList" + $TextFileCounter + ".txt")

        foreach ($File in $Files) {
            if ($FileCounter -eq $MaxFilenamesPerFile) {
                $FileCounter = 0
                $TextFileCounter++
                $FileListsArr += $TextFilePath
                $TextFilePath = Join-Path $TempDirectory ("FileList" + $TextFileCounter + ".txt")
            }
            
            $File | Out-File -Append -FilePath $TextFilePath
            $FileCounter++

            Write-Host "`$File:" $File -ForegroundColor Green
            Write-Host "`$Files.Count:" $Files.Count -ForegroundColor Green
            Write-Host "`$AbsoluteFileCounter:" $AbsoluteFileCounter -ForegroundColor Green

            if($AbsoluteFileCounter -eq $Files.Count){
                $FileListsArr += $TextFilePath
            }

            $AbsoluteFileCounter++
        }

        $CMD = Get-Command "C:\Program Files (x86)\ReNamer\ReNamer.exe"
        $FileListsArr | ForEach-Object -Parallel {
            $List = $_
            $Preset = $Using:PresetName
            $Command = $Using:CMD
            $Params = '/rename', $Preset, '/list', $List
            & $Command $Params | Out-Null
        } -ThrottleLimit 4
    }
}

