function Get-NewVersions {
    [OutputType([VersionData[]])]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = "url")]
        [string]$packageName,
        [Parameter(Mandatory = $true, ParameterSetName = "page")]
        [Microsoft.PowerShell.Commands.BasicHtmlWebResponseObject]$packagePage,
        [VersionData[]]$existingVersions = $null
    )
    $isUpdate = $PSCmdlet.MyInvocation.InvocationName -eq "Get-UpdatedVersions"

    $versions = [System.Collections.Generic.List[VersionData]]::new()

    if ($isUpdate -and (!$existingVersions -or $existingVersions.Count -eq 0)) {
        return $versions
    }

    $url = "https://chocolatey.org/api/v2/package-versions/${packageName}?includePreRelease=true"

    [array]$jsonVersions = Invoke-RestMethod -Uri $url -UseBasicParsing | Select-Object -Unique
    $apiVersions = $jsonVersions | ForEach-Object { [SemanticVersion]::create($_) } | Sort-Object -Property VersionOnly, Tag -Descending | Select-Object -Unique -First 5

    $breakOnFound = @('approved'; 'exempted'; 'unknown')

    foreach ($version in $apiVersions) {
        if ($existingVersions -and $existingVersions.Count -ge 0) {
            $foundVersion = $existingVersions | Where-Object { $_.version.Raw -eq $version.Raw }
            if ($foundVersion -and $breakOnFound.Contains($foundVersion.status)) {
                break
            }
            elseif (!$foundVersion -or $isUpdate) {
                $versionData = Get-VersionData -packageName $packageName -version $version
                if ($isUpdate) {
                    $index = $existingVersions.IndexOf($foundVersion)
                    $existingVersions[$index] = $versionData
                    $versions.Add($versionData)
                }
                elseif ($foundVersion -and $foundVersion.status -ne $versionData.status) {
                    $versionData.isNew = !$isUpdate
                    $versions.Add($versionData)
                }
            }
        }
        elseif (!$isUpdate) {
            $versionData = Get-VersionData -packageName $packageName -version $version
            $versions.Add($versionData)
        }
    }

    if ($versions.Count -eq 0) {
        Write-Verbose "No new package versions was found."
    }

    return $versions
}

Set-Alias -Name Get-UpdatedVersions -Value Get-NewVersions
