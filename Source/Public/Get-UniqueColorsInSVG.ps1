function Get-UniqueColorsInSVG {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        $SVGFile
    )

    begin {
        $xmlDoc = [System.Xml.XmlDocument]::new()
        $nsmgr = [System.Xml.XmlNamespaceManager]::new($xmlDoc.NameTable);
        $nsmgr.AddNamespace("xsl", "http://www.w3.org/1999/XSL/Transform");
        $nsmgr.AddNamespace("svg", "http://www.w3.org/2000/svg");
    }

    process {

        $xmlDoc.Load((Convert-Path $SVGFile))
        $uniqueColors = [System.Collections.Generic.HashSet[System.Drawing.Color]]::new()

        [System.Xml.XmlNodeList]$lgrad = $xmlDoc.SelectNodes("//svg:linearGradient", $nsmgr)
        [System.Xml.XmlNodeList]$rgrad = $xmlDoc.SelectNodes("//svg:radialGradient", $nsmgr)
        if (($lgrad.Count -gt 0) -or ($rgrad.Count -gt 0)) {
            $PSCmdlet.ThrowTerminatingError([System.Management.Automation.ErrorRecord]::new(
                    [System.Exception]::new("SVG has gradients. This isn't supported."),
                    "GrandientNotSupported",
                    [System.Management.Automation.ErrorCategory]::NotImplemented,
                    $xmlDoc))
        }

        [System.Xml.XmlNodeList]$stylenode = $xmlDoc.SelectNodes("//svg:style", $nsmgr)


        foreach ($node in $stylenode) {
            $styleText = $node.InnerText
            $styleText | Select-String -Pattern '(?s)fill:([^;]+)' -AllMatches | ForEach-Object {
                $_.Matches | ForEach-Object {
                    $extractedValue = $_.Groups[1].Value.Trim()
                    if ($extractedValue -and ($potentialColor = $extractedValue.Replace('grey', 'gray') -replace '#(.)(.)(.)$','#$1$1$2$2$3$3' -as [System.Drawing.Color])){
                        $uniqueColors.Add($potentialColor) | Out-Null
                    }
                }
            }
        }

        [System.Xml.XmlNodeList]$pathStyleAttributes = $xmlDoc.SelectNodes("//svg:path/@style", $nsmgr)
        foreach ($node in $pathStyleAttributes) {
            $PathStyleAttribute = $node.Value
            if ($PathStyleAttribute -match 'fill:([^;]+)' -and ($potentialColor = $Matches[1].Trim().Replace('grey', 'gray') -replace '#(.)(.)(.)$','#$1$1$2$2$3$3' -as [System.Drawing.Color])) {
                $uniqueColors.Add($potentialColor) | Out-Null
            }
        }

        'path', 'rect', 'circle', 'elipse', 'polygon', 'polyline', 'text', 'textPath', 'tref', 'tspan', 'g' | ForEach-Object {
            foreach ($node in $xmlDoc.SelectNodes("//svg:$_/@fill", $nsmgr)) {
                $fillText = $node.Value
                if ($fillText -and ($potentialColor = $fillText.Replace('grey', 'gray') -replace '#(.)(.)(.)$','#$1$1$2$2$3$3' -as [System.Drawing.Color])) {
                    $uniqueColors.Add($potentialColor) | Out-Null
                }
            }
        }

        #Convert RGB to HEX
        $ColorCodes = @(
            foreach ($color in $uniqueColors) {
                '#{0:X6}' -f ($color.ToArgb() -band 0xFFFFFF)
            }
        )

        if($ColorCodes.Length -eq 0){
            Write-Host "The SVG has no fill color definitions."
        }else{
            $ColorCodes
        }
    }
}