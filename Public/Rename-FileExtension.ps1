
function Rename-FileExtension {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory=$true,
            Position=0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            HelpMessage='File should be set to a single file path, or an array of file paths.')] 
        [string[]]$File,

        [Parameter(
            Mandatory=$true,
            HelpMessage=    'NewExtension should be set to a valid file extension. 
                            No invalid file path characters, and no longer than 9 digits.'
            )]
        [String] 
        $NewExtension
    )

    begin {

        if($NewExtension.Length -gt 9){
            throw "NewExtension is out of bounds. Enter a value between 1-9 characters."
        }

        $invalidChars = [System.IO.Path]::GetInvalidFileNameChars()
        # Check if the string contains any of the invalid characters
        foreach ($char in $invalidChars) {
            if ($NewExtension.Contains($char)) {
                throw "NewExtension contains invalid filename characters."
                break
            }
        }

    }

    process {

        foreach ($F in $File){
            
            if ($NewExtension -match '^[a-zA-Z0-9]{1,8}$') {
                [System.String]$FinalExtension = "." + $matches[0]

            }elseif ($NewExtension -match '^\.[a-zA-Z0-9]+$'){
                [System.String]$FinalExtension = $matches[0]
            }

            $FinalExtension = $FinalExtension.ToLower()

            $FilePathNoExtension = $File.Substring(0, $File.LastIndexOf('.'))
            $NewFile = ($FilePathNoExtension + $FinalExtension)

            Rename-Item $F -NewName $NewFile

        }
    }
}