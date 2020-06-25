function Get-NewMaintainers {
    param (
        [Parameter(Mandatory = $true, ParameterSetName = "name")]
        [string]$packageName,
        [Parameter(Mandatory = $true, ParameterSetName = "page")]
        [Microsoft.PowerShell.Commands.BasicHtmlWebResponseObject]$packagePage,
        [MaintainerData[]]$existingMaintainers = $null
    )

    $isUpdate = $PSCmdlet.MyInvocation.InvocationName -eq "Get-UpdatedMaintainers"

    $maintainers = [System.Collections.Generic.List[MaintainerData]]::new()

    if (!$packagePage) {
        try {
            $packagePage = Invoke-WebRequest -Uri "https://chocolatey.org/packages/${packageName}" -UseBasicParsing
        }
        catch {
            return $maintainers
        }
    }

    [array]$currentMaintainers = $packagePage.Links | `
        ? { $_.href -match "\/profiles/[a-z0-9_\.-]+$" } | `
        % { $_.href -split "\/" | Select-Object -Last 1 } | `
        select -Unique

    foreach ($maintainer in $currentMaintainers) {
        $foundMaintainer = $existingMaintainers | ? username -eq $maintainer

        if (!$foundMaintainer) {
            $newMaintainer = [MaintainerData]::new()
            $newMaintainer.username = $maintainer
            $newMaintainer.url = [uri]::new("https://chocolatey.org/profiles/$maintainer")
            $newMaintainer.status = if ($isUpdate) { "added" } else { "initial" }
            $maintainers.Add($newMaintainer)
        }
        else {
            if (!$foundMaintainers.status) {
                $foundMaintainer.status = "initial"
            }
            $maintainers.Add($foundMaintainer)
        }
    }

    return $maintainers
}

Set-Alias -Name Get-UpdatedMaintainers -Value Get-NewMaintainers
