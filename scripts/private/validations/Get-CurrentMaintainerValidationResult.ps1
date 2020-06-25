<#
.SYNOPSIS
    Validates the current request using current maintainer rules
.PARAMETER issueData
    The issue data for the current request
.PARAMETER validationData
    The validation data storage for the current request
#>
function Get-CurrentMaintainerValidationResult {
    param(
        [Parameter(Mandatory = $true)]
        [IssueData]$issueData,
        [Parameter(Mandatory = $true)]
        [ValidationData]$validationData
    )

    $userIsKnownMaintainer = $false
    if (Test-Path "$PSScriptRoot/../../users.json") {
        $allStoredUsers = Get-Content "$PSScriptRoot/../../users.json" -Encoding utf8NoBOM | ConvertFrom-Json
        $storedUser = $allStoredUsers | ? github -eq $issueData.userLogin
        if ($storedUser) {
            $userIsKnownMaintainer = $validationData.packageMaintainers | ? { $_ -eq $storedUser.choco }
        }
    }

    $compareData = @{
        issueData      = $issueData
        validationData = $validationData
    }

    Write-Host ([StatusCheckMessages]::checkMarkedAsCurrentMaintainer)
    $re = "(?i)\[[\sx]*\]\s*(I am the maintainer of the package)"
    if ($userIsKnownMaintainer) {
        if (Compare-Body @compareData -re $re) {
            Update-ValidationBody -issueData $issueData -validationData $validationData -replacement $re, "[x] `${1}"
        }
        else {
            Write-WarningMessage ([WarningMessages]::userIsKnowMaintainerMissingConfirmationPart)
            Update-StatusLabel -validationData $validationData -label ([StatusLabels]::incompleteRequest)
            Add-ValidationMessage -validationData $validationData -message ([ValidationMessages]::currentMaintainerCheckboxMissingError) -type ([MessageType]::Error)
        }
    }
    else {
        if (Compare-Body @compareData -re $re) {
            Update-ValidationBody -issueData $issueData -validationData $validationData -replacement $re, "[ ] `${1}"
        }

        Write-WarningMessage ([WarningMessages]::userNotKnownMaintainerOfPackage)
        if ($allStoredUsers | ? github -eq $issueData.userLogin) {
            $errMsg = [ValidationMessages]::currentMaintainerNotVerifiedUserIsKnownError
        }
        else {
            $errMsg = [ValidationMessages]::currentMaintainerNotVerifiedUserIsUnknownError
        }

        Update-StatusLabel -validationData $validationData -label ([StatusLabels]::incompleteRequest)
        Add-ValidationMessage -validationData $validationData -message $errMsg -type ([MessageType]::Error)
    }

    # Validate that the template do not contain the date the maintainer was contacted
    Write-Host ([StatusCheckMessages]::checkUserRemovedMaintainerContactedDate)
    $re = "(?smi)^Date the maintainer was contacted[^\r\n]*[\r\n]$"
    if (Compare-Body @compareData -re $re) {
        Write-WarningMessage ([WarningMessages]::userNotRemovedMaintainerContactedDate)
        Update-ValidationBody -issueData $issueData -validationData $validationData -replacement $re, ""
    }

    $re = "(?smi)^How the maintainer was contacted[^\r\n]*[\r\n]$"
    if (Compare-Body @compareData -re $re) {
        Update-ValidationBody -issueData $issueData -validationData $validationData -replacement $re, ""
    }

    if (!($validationData.messages | ? { $_.type -eq [MessageType]::Error -or $_.type -eq [MessageType]::Warning })) {
        Update-StatusLabel -validationData $validationData -label ([StatusLabels]::availableRequest)
    }

    return $true
}
