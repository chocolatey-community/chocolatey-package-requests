function Get-PackageData {
    [OutputType([PackageData])]
    param (
        [Parameter(Mandatory = $true)]
        [string]$packageName
    )

    try {
        $chocoPage = Invoke-WebRequest -Uri "https://chocolatey.org/packages/$packageName" -UseBasicParsing
    }
    catch {
        return $null
    }

    $types = "(install|portable|commandline|app)"

    $childPackage = $chocoPage.Links | `
        Where-Object href -match "^\/.*packages\/$packageName\.$types($|\/)" | `
        ForEach-Object {
        $url = $_.href
        if ($url -notmatch "\.$types$") {
            $url -split "\/" | Select-Object -Last 1 -Skip 1
        }
        else {
            $url -split "\/" | Select-Object -Last 1
        }
    } | `
        Select-Object -First 1 # There should only be one, but just in case

    $result = [PackageData]::new()
    $result.name = $packageName
    $result.maintainers = Get-NewMaintainers -packagePage $chocoPage
    $result.child = $childPackage

    $result.versions = Get-NewVersions -packageName $packageName

    return $result
}
