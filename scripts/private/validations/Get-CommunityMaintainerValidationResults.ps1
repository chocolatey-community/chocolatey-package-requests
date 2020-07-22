<#
.SYNOPSIS
    Validates the current request using rules for community users
.PARAMETER issueData
    The issue data for the current request
.PARAMETER validationData
    The validation data storage for the current request
#>
function Get-CommunityMaintainerValidationResults() {
    param(
        [Parameter(Mandatory = $true)]
        [IssueData]$issueData,
        [Parameter(Mandatory = $true)]
        [ValidationData]$validationData
    )

    $compareData = @{
        issueData      = $issueData
        validationData = $validationData
    }

    Write-Host ([StatusCheckMessages]::checkMarkedAsFollowingTriageProcess)
    $re = "\[x\]\s*I have followed the Package Triage Process"
    if (!(Compare-Body @compareData -re $re)) {
        Write-WarningMessage ([WarningMessages]::userNotSelectedTriageProcessFollowed)
        Update-StatusLabel -validationData $validationData -label ([StatusLabels]::incompleteRequest)
        Add-ValidationMessage -validationData $validationData -message ([ValidationMessages]::triageProcessNotFollowedError) -type ([MessageType]::Error)
    }

    Write-Host ([StatusCheckMessages]::checkMarkedAsSearchedForIssues)
    $re = "\[x\]\s*There is no existing open maintainer"
    if (!(Compare-Body @compareData -re $re)) {
        Write-WarningMessage ([WarningMessages]::userNotSelectedSearchingForIssues)
        Update-StatusLabel -validationData $validationData -label ([StatusLabels]::incompleteRequest)
        Add-ValidationMessage -validationData $validationData -message ([ValidationMessages]::githubSearchNotMarkedError -f $validationData.repository, $validationData.packageName) -type ([MessageType]::Error)
    }

    Write-Host ([StatusCheckMessages]::checkUserSuppliedMaintainerContactDate)
    $re = "Date the maintainer was contacted\s*\(in YYYY-MM-DD\)\s*:\s(\d{4}-\d{2}-\d{2})"
    if (!(Compare-Body @compareData -re $re)) {
        Write-WarningMessage ([WarningMessages]::userNotSpecifiedContactDateOfMaintainer)
        Update-StatusLabel -validationData $validationData -label ([StatusLabels]::incompleteRequest)
        Add-ValidationMessage -validationData $validationData -message ([ValidationMessages]::maintainerContactedDateMissingError) -type ([MessageType]::Error)
    }

    # TODO Validate contact date being larger than 7 days (maybe)

    Write-Host ([StatusCheckMessages]::checkUserSuppliedMaintainerContactMethod)
    $re = "How the maintainer was contacted\s*:\s*[\S]+[a-z]"
    if (!(Compare-Body @compareData -re $re)) {
        Write-WarningMessage ([WarningMessages]::userNotSpecifiedContactMethodOfMaintainer)
        Update-StatusLabel -validationData $validationData -label ([StatusLabels]::incompleteRequest)
        Add-ValidationMessage -validationData $validationData -message ([ValidationMessages]::maintainerContactedMethodMissingError) -type ([MessageType]::Error)
    }

    return $true
}
