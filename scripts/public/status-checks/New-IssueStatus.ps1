function New-IssueStatus {
    param (
        [Parameter(Mandatory = $true)]
        [int]$issueNumber,
        [Parameter(Mandatory = $true)]
        [string]$repository,
        [string]$commentUser = $null
    )
    $issueData = Get-Issue @PSBoundParameters

    $commentData = Get-Comment @PSBoundParameters -contentMatch "<!-- START STATUS DATA"

    # Need permission check

    # I wanted a force parameter, but github actions only fails with switches it seems
    if ($commentData -and $commentUser) {
        Write-WarningMessage "Status data have already been initialized. Exiting..."
        Add-Comment @PSBoundParameters -commentBody "@$commentUser Status data have already been initialized. Please use ``/status show`` to show the stored data, or ``/status check`` to check for updated data."

        return
    }

    $packageName = $issueData.title -replace "^RF[PM]\s*-\s*(.*)\s*$", "`${1}"

    $statusData = @()

    $mainPkg = Get-PackageData -packageName $packageName

    if ($mainPkg) {
        $statusData = @($mainPkg)
        if ($mainPkg.child) {
            $childPkg = Get-PackageData -packageName $mainPkg.child
            if ($childPkg) {
                $statusData += @($childPkg)
            }
        }
    }

    $arguments = @{
        repository  = $repository
        packageName = $packageName
        statusData  = $statusData
    }

    if ($commentData) {
        $arguments["commentId"] = $commentData.id
    }
    else {
        $arguments["issueNumber"] = $issueData.number
    }

    Update-StatusComment @arguments
}
