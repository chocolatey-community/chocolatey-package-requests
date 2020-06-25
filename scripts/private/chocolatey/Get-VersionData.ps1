
function Get-VersionData {
    param(
        [Parameter(Mandatory = $true)]
        [string]$packageName,
        [Parameter(Mandatory = $true)]
        [SemanticVersion]$version
    )

    $versionData = [VersionData]::new()
    $versionData.version = $version
    $versionData.status = "unknown"
    $versionData.listed = $false

    $url = "https://chocolatey.org/api/v2/Packages(Id='$packageName',Version='$($version.Raw)')"

    try {
        $packagePage = Invoke-RestMethod -Uri $url -UseBasicParsing
    }
    catch {
        $versionData.url = "https://chocolatey.org/packages/${packageName}/$($version.Raw)"
        $versionData.status = "rejected" # This is an assumption when it can not be found using the api
    }

    $properties = $packagePage.entry.properties
    $versionData.url = $properties.GalleryDetailsUrl
    $isApproved = $properties.IsApproved.InnerText
    $published = [datetime]::Parse($properties.Published.InnerText)

    if ($published -gt [datetime]::UnixEpoch) {
        # Unix epoch is returning 01.01.1970, there should be no packages before this date
        $versionData.listed = $true
    }

    if ([bool]::Parse($isApproved)) {
        $versionData.status = "approved"
    }
    elseif ($properties.PackageStatus -eq "Exempted") {
        $versionData.status = "exempted"
    }
    elseif ($properties.PackageStatus -eq "Submitted") {
        if ($properties.PackageSubmittedStatus -eq "Waiting") {
            $versionData.status = "waiting"
        }
        else {
            $versionData.status = "submitted"
        }
    }
    else {
        # Anything else would most likely be an unknown status
    }

    return $versionData
}
