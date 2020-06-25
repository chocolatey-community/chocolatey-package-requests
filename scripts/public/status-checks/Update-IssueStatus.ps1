function Update-IssueStatus {
    param (
        [Parameter(Mandatory = $true)]
        [int]$issueNumber,
        [Parameter(Mandatory = $true)]
        [string]$repository,
        [string]$commentUser
    )
    $issueData = Get-Issue @PSBoundParameters

    if ($issueData.state -eq "closed") {
        return
    }

    $commentData = Get-Comment @PSBoundParameters -contentMatch "<!-- START STATUS DATA"

    if (!$commentData) {
        New-Status @PSBoundParameters
        return
    }

    $startComment = "<!-- START STATUS DATA"
    $endComment = "END STATUS DATA -->"
    $startIndex = $commentData.body.IndexOf($startComment)
    if ($startIndex -ge 0) {
        $startIndex += $startComment.Length
        $endIndex = $commentData.body.IndexOf($endComment, $startIndex)
        if ($endIndex -ge 0) {
            $data = $commentData.body.Substring($startIndex, $endIndex - $startIndex)
            $data = [Newtonsoft.Json.JsonConvert]::DeserializeObject($data, [PackageData[]])
        }
        else {
            New-Status @PSBoundParameters -force
            return
        }
    }
    else {
        New-Status @PSBoundParameters -force
        return
    }

    $newData = [System.Collections.Generic.List[PackageData]]::new()

    $respondComment = ""
    $statusLabel = $null
    $issueState = $issueData.state
    [string[]]$assignedUsers = $issueData.assignees

    if ($assignedUsers) {
        $statusLabel = [StatusLabels]::inProgressRequest
    }
    else {
        $assignedUsers = @()
        # Unsure if we should move it back when it is in a review request as well
        # maybe even unassigning users should require moving the label to available request
        # manually even?
        if ($issueData.labels | ? { $_ -eq [StatusLabels]::inProgressRequest } ) {
            $statusLabel = [StatusLabels]::availableRequest
        }
    }


    $allLabels = $data | ForEach-Object {
        $pkg = $_
        $pkgName = $pkg.name
        $currentMaintainers = Get-UpdatedMaintainers -packageName $pkgName -existingMaintainers $pkg.maintainers

        $currentMaintainers | Where-Object {
            $maint = $_
            !($pkg.maintainers | Where-Object {
                    $_.username -eq $maint.username
                })
        } | ForEach-Object {
            $respondComment = "$respondComment`nThe chocolatey user [$($_.username)]($($_.url)) have been added to the [$pkgName](https://chocolatey.org/packages/${pkgName}) package."
            $knownUser = Get-KnownUser -chocolatey $_.username
            if ($_.status -eq "initial") {
                # Ignored on purpose, we don't want to assign initial users
            }
            elseif ($knownUser -and !$assignedUsers.Contains($knownUser.github)) {
                $respondComment = "${respondComment} Assigning known github user @$($knownUser.github) to the issue."
                $assignedUsers = $assignedUsers + @($knownUser.github) | Sort-Object -Unique
                $statusLabel = [StatusLabels]::inProgressRequest
            }
            elseif (!$knownUser) {
                $respondComment = "${respondComment} There is no known github user connected with this chocolatey user. **Manual assignment is needed...**"
            }
        }
        $pkg.maintainers | Where-Object {
            $maint = $_
            $maint -and !($currentMaintainers | Where-Object {
                    $_.username -eq $maint.username
                })
        } | ForEach-Object {
            $respondComment = "$respondComment`nThe chocolatey user [$($_.username)]($($_.url)) have been removed from the [$pkgName](https://chocolatey.org/packages/${pkgName}) package."
            if ($issueData.assignees -and $issueData.assignees.Count -gt 0) {
                $knownUser = Get-KnownUser -chocolatey $_.username
                if ($knownUser -and $assignedUsers.Contains($knownUser.github)) {
                    $respondComment = "$respondComment Removing assigned user @$($knownUser.github) from the issue."
                    [array]$assignedUsers = $assignedUsers | Where-Object { $_ -ne $knownUser.github }
                }
            }
        }

        $updatedVersions = Get-UpdatedVersions -packageName $pkgName -existingVersions $pkg.versions
        if (!$updatedVersions -or $updatedVersions.Count -eq 0) {
            if ($pkg.versions -or !$statusLabel) {
                $issueData.labels | Where-Object { $_ -match "^$([regex]::Escape([StatusLabels]::statusLabelPrefix))" }
            }
            else {
                $statusLabel
            }
        }

        $index = 0
        $closeIssue = $false

        $updatedVersions | ForEach-Object {
            $version = $_
            $oldVersion = $pkg.versions | Where-Object { $_.version.Raw -eq $version.version.Raw }
            if ($oldVersion.status -and $_.status -eq $oldVersion.status) {
                # Empty on purpose, if the status have not changed nothing to do
                # We would still wish to update the data stored though
            }
            elseif ($_.status -eq "submitted" -and $oldVersion -and $oldVersion.status -eq 'rejected') {
                $comment = "The rejected package version [$($_.version.Raw)]($($_.url)) have been unrejected and seems to be in progress."
                [StatusLabels]::inProgressRequest
            }
            elseif ($_.status -eq "submitted") {
                $comment = "The package version [$($_.version.Raw)]($($_.url)) have been submitted/updated and is now awaiting review.."
                [StatusLabels]::reviewRequest
            }
            elseif ($_.status -eq "waiting") {
                $comment = "The package version [$($_.version.Raw)]($($_.url)) have failed automated checks, or a reviewer requested changes. Moving back to In Progress status..."
                [StatusLabels]::inProgressRequest
            }
            elseif ($_.status -eq "approved" -or $_.status -eq "exempted") {
                $comment = "The package version [$($_.version.Raw)]($($_.url)) have been approved/exempted by a reviewer."
                [StatusLabels]::publishedRequest
                $closeIssue = $true
            }
            else {
                $statusLabel
            }

            if ($oldVersion) {
                $oldVersion.status = $_.status
                $oldVersion.listed = $_.listed
            }
            else {
                $pkg.versions = @($pkg.versions | Select-Object -First $index) + @($version) + @($pkg.versions | Select-Object -Skip $index)
                $index += 1 # Just to make sure we don't send anything back up
            }

            if ($comment) {
                $respondComment = "$respondComment`n$comment"
            }
        }

        $pkg.maintainers = @($currentMaintainers)
        $newData.Add($pkg)
    }

    $publishDowngrade = @([StatusLabels]::inProgressRequest; [StatusLabels]::reviewRequest; [StatusLabels]::availableRequest)
    $reviewDowngrade = @([StatusLabels]::inProgressRequest; [StatusLabels]::availableRequest)
    $inProgressDowngrade = @([StatusLabels]::availableRequest)
    $statusLabel = [StatusLabels]::publishedRequest

    foreach ($label in $allLabels) {
        if ($statusLabel -eq $label) {
            continue
        }
        if (($statusLabel -eq [StatusLabels]::publishedRequest) -and $publishDowngrade.Contains($label)) {
            $statusLabel = $label
        }
        elseif (($statusLabel -eq [StatusLabels]::reviewRequest) -and $reviewDowngrade.Contains($label)) {
            $statusLabel = $label
        }
        elseif (($statusLabel -eq [StatusLabels]::inProgressRequest) -and $inProgressDowngrade.Contains($label)) {
            #Future use perhaps
            $statusLabel = $label
        }
    }

    if (!$assignedUsers) {
        [string[]]$assignedUsers = @()
    }
    else {
        [string[]]$assignedUsers = $assignedUsers | select -unique
    }

    if ($closeIssue) {
        $respondComment = "$respondComment`n`nAll monitored packages have a new version that was approved/exempted. Closing issue.."
        "`nWould close issue due to being published"
        $issueState = 'closed'
    }
    elseif (!$closeIssue -and $statusLabel -eq [StatusLabels]::publishedRequest) {
        Write-ErrorMessage "Something went wrong with checking for current status of a package. Please investigate"
        return
    }

    $commentArgs = @{
        commentId   = $commentData.id
        packageName = $data[0].name
        repository  = $repository
        statusData  = $newData
    }

    Update-StatusComment @commentargs

    [array]$labels = $issueData.labels | Where-Object { $_ -notmatch "^$([regex]::Escape([StatusLabels]::statusLabelPrefix))" }
    $labels += @($statusLabel)

    if ($commentUser) {
        $respondComment = "@${commentUser}`n$respondComment"
    }

    "Using the following labels $labels"
    "Using the following assigned people $assignedUsers"
    "Setting issue as: $issueState"

    if ($respondComment) {

        Add-Comment @PSBoundParameters `
            -commentBody $respondComment
    }

    try {

        Update-Issue @PSBoundParameters `
            -assignees $assignedUsers `
            -labels $labels `
            -state $issueState
    }
    catch {
        # if this fails we assume it is because we could not assign the user
        Update-Issue @PSBoundParameters `
            -labels $labels `
            -state $issueState
        Add-Comment @PSBoundParameters `
            -commentBody "We was unable to assign a user to the issue. Please do this manually..."
    }


    $respondComment
}
