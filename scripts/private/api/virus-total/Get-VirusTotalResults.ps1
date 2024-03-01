function Get-JsonResults {
    param(
        $inputObject
    )

    try {
        # we first try normal serialization
        return $inputObject | ConvertFrom-Json
    }
    catch {}

    try {
        # next we try to serialize as hash table
        return $inputObject | ConvertFrom-Json -AsHashtable
    }
    catch {}

    # at the end we just return the object as is
    $inputObject
}

function Get-VirusTotalResults {
    param(
        [Parameter(Mandatory = $true)]
        [string]$filePath
    )

    if (!(Test-Path Env:\VIRUS_TOTAL_API_KEY)) {
        return @{
            Status     = "NoApiKey"
            Flagged    = 0
            TotalCount = 0
            Url        = $null
        }
    }

    Write-Host ([StatusCheckMessages]::virusTotalCheck)
    $checksum = (Get-FileHash $filePath -Algorithm SHA256 | % Hash).ToLowerInvariant()
    $apiUrl = "https://www.virustotal.com/api/v3/files/{0}" -f $checksum
    $headers = @{
        "x-apikey" = $env:VIRUS_TOTAL_API_KEY
    }

    try {
        $response = Invoke-RestMethod -UseBasicParsing -Uri $apiUrl -Method Get -Headers $headers
        $response = Get-JsonResults -inputObject $response

        $stats = $response.data.attributes.last_analysis_stats

        Write-Host ([StatusMessages]::virusTotalResultsAvailable)

        @{
            Status     = "Found"
            Flagged    = ($stats.malicious + $stats.suspecious)
            TotalCount = $response.data.attributes.last_analysis_results.Count - $stats.'type-unsupported'
            Url        = "https://www.virustotal.com/gui/file/{0}" -f $checksum
        }
    }
    catch {
        # We will assume this means that no virus results are available.
        # VirusTotal seems to return 404 when none are uploaded
        Write-Host ([StatusMessages]::noVirusTotalStatusAvailable)
        @{
            Status     = "NotFound"
            Flagged    = 0
            TotalCount = 0
            Url        = "https://www.virustotal.com/gui/file/{0}" -f $checksum
        }
    }
}
