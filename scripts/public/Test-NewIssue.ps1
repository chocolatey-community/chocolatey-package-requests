$ErrorActionPreference = 'Stop'

<#
.SYNOPSIS
    Runs a full validation check on the current request
.PARAMETER issueNumber
    The issue number to run the validation on
.PARAMETER commentId
    The unique identifier of the comment that initiated
    a new validation check
.PARAMETER repository
    The repository the validation check should be run on.
#>
function Test-NewIssue {
    param (
        [Parameter(Mandatory = $true, ParameterSetName = "issue")]
        [int]$issueNumber,
        [Parameter(Mandatory = $true, ParameterSetName = "comment")]
        [int]$commentId,
        [string]$repository = $env:GITHUB_REPOSITORY
    )

    if ($commentId) {
        $commentData = Get-Comment -commentId $commentId -repository $repository
        $issueData = Get-Issue -issueUrl $commentData.issue_url
    }
    else {
        $issueData = Get-Issue -issueNumber $issueNumber -repository $repository
    }

    if ($issueData.assignees.Count -gt 0) {
        Write-Host ([StatusMessages]::userAssignedToIssue)

        if ($commentId) {
            $msg = [PermissionMessages]::issueUserAssigned -f $commentData.userLogin
            Submit-Comment -issueNumber $issueData.number -repository $repository -commentBody $msg
        }
        return
    }

    $statusLabels = $issuedata.labels | Where-Object { $_ -match "^$([StatusLabels]::statusLabelPrefix)" }
    if ($statusLabels | Where-Object { -not ($_ -eq [StatusLabels]::triageRequest -or $_ -eq [StatusLabels]::incompleteRequest) }) {
        Write-Host ([StatusMessages]::issueHaveBeenLabeled)

        $msg = [PermissionMessages]::issueLabelAssigned -f $commentData.userLogin, ([StatusLabels]::triageRequest), ([StatusLabels]::incompleteRequest)
        Submit-Comment -issueNumber $issueData.number -repository $repository -commentBody $msg
        return
    }
    $validationData = [ValidationData]::new()
    $validationData.repository = $repository
    Update-StatusLabel -validationData $validationData -label ([StatusLabels]::triageRequest)

    $arguments = @{
        issueData      = $issueData
        validationData = $validationData
    }

    $result = Get-CommonValidationResults @arguments

    Format-Checkboxes @arguments

    if ($result -and $arguments.validationData.isNewPackageRequest) { $result = Get-NewPackageValidationResult @arguments }
    if ($result -and !$arguments.validationData.isNewPackageRequest) { $result = Get-CommonMaintainerValidationResult @arguments }

    if ($result) {
        Write-Host ([StatusCheckMessages]::checkingForExistingIssues -f $validationData.packageName)
        $existingIssues = Search-Issues -query "repo:$($validationData.repository)+state:open+in:title $($validationData.packageName)" -repository $validationData.repository | Where-Object number -ne $issueData.number
        if ($existingIssues) {
            $existing = ($existingIssues | ForEach-Object { "[$($_.title)]($($_.html_url))" } ) -join ", "

            $noticeMsg = [ValidationMessages]::issuesFoundNotice -f $existing

            Update-StatusLabel -validationData $validationData -label ([StatusLabels]::triageRequest)
            Add-ValidationMessage -validationData $validationData -message $noticeMsg -type ([MessageType]::Warning)
        }
    }


    $arguments = @{
        issueUrl = $issueData.url
    }

    $arguments["labels"] = [array]($existingLabels + $validationData.newLabels) | Select-Object -Unique

    if ($validationData.newBody -and $validationData.newBody -cne $issueData.body) {
        $arguments["description"] = $validationData.newBody
    }
    if ($validationData.newTitle -and $validationData.newTitle -cne $issueData.title) {
        $arguments["title"] = $validationData.newTitle
    }

    $issueData = Update-Issue @arguments


    $commentBody = [ValidationMessages]::commentBodyDetection + "`n" + [ValidationMessages]::commentBodyHeader

    if (!($validationData.messages | Where-Object type -NE ([MessageType]::Info))) {
        if ($validationData.newLabels.Contains([StatusLabels]::availableRequest)) {
            $commentBody += "`n`n" + [ValidationMessages]::availableSuccess
        }
        else {
            $commentBody += "`n`n" + [ValidationMessages]::triageSuccess
        }
    }
    else {
        $errors = $validationData.messages | Where-Object type -EQ ([MessageType]::Error)
        if ($errors) {
            $commentBody += "`n`n" + [ValidationMessages]::errorsHeader
            $errors | ForEach-Object {
                $commentBody += "`n- $($_.message)"
            }
        }
        $warnings = $validationData.messages | Where-Object type -EQ ([MessageType]::Warning)
        if ($warnings) {
            $commentBody += "`n`n" + [ValidationMessages]::noticesHeader
            $warnings | ForEach-Object {
                $commentBody += "`n- $($_.message)"
            }
        }
    }

    $infos = $validationData.messages | Where-Object type -EQ ([MessageType]::Info)
    if ($infos) {
        $commentBody += "`n`n" + [ValidationMessages]::maintainersHeader
        $infos | ForEach-Object {
            $commentBody += "`n- $($_.message)"
        }
    }

    $commentBody += [ValidationMessages]::commentBodyFooter

    Write-Host ([StatusCheckMessages]::checkingExistingValidationComment)
    $commentsData = Get-Comment -issueNumber $issueData.number -contentMatch ([regex]::Escape([ValidationMessages]::commentBodyDetection)) -repository $repository

    if ($commentsData) {
        Remove-Comment $commentsData.id -repository $repository
    }

    Add-Comment -issueNumber $issueData.number -repository $repository -commentBody $commentBody

    if ($validationData.newLabels.Contains([StatusLabels]::availableRequest)) {
        # Since github-action bot do not trigger workflows, we call New-Status directly here
        # we also force it in case as we want the initial status to be what is right now
        # even if there already is a status comment
        New-Status -issueNumber $issueData.number -repository $repository -force
    }
}
