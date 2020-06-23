<#
.SYNOPSIS
    Validates the current request as a maintainer request
.PARAMETER issueData
    The issue data for the current request
.PARAMETER validationData
    The validation data storage for the current request
.OUTPUTS
    Returns $false if validator should abort further processing, otherwise $true
#>
function Get-CommonMaintainerValidationResult() {
    param(
        [Parameter(Mandatory = $true)]
        [IssueData]$issueData,
        [Parameter(Mandatory = $true)]
        [ValidationData]$validationData
    )

    Write-Host ([StatusCheckMessages]::checkingValidMaintainerHeaderUsed)
    $currentMaintainer = $issueData.body -match "#\s*Current Maintainer"
    $notMaintainer = $issueData.body -match "#\s*I DON'T Want To Become The Maintainer"

    if ($currentMaintainer -and $notMaintainer) {
        Write-WarningMessage ([WarningMessages]::userUsedBothCurrentMaintainerAndCommunityUserTemplate)
        Update-StatusLabel -validationData $validationData -label ([StatusLabels]::incompleteRequest)
        Add-ValidationMessage -validationData $validationData -message ([ValidationMessages]::bothMaintainerSectionsUsedError) -type ([MessageType]::Error)
        return $false
    }

    $compareData = @{
        issueData      = $issueData
        validationData = $validationData
    }

    Write-Host ([StatusCheckMessages]::checkUserMarkedWithCorrectRFMTitle)
    $re = "(?i)\[[\sx]*\]\s*(Issue title starts with 'RFM)"
    if ((Compare-Body @compareData -re $re) -and ($issueData.title -match "^RFM" -or $validationData.newTitle -match "^RFM")) {
        Write-Host ([StatusMessages]::uncheckedRFMItemFound)
        Update-ValidationBody -issueData $issueData -validationData $validationData -replacement $re, "[x] `${1}"
    }
    else {
        Write-WarningMessage ([WarningMessages]::templateMissingRFMCheckbox)
        Update-StatusLabel -validationData $validationData -label ([StatusLabels]::incompleteRequest)
        Add-ValidationMessage -validationData $validationData -message ([ValidationMessages]::issueMissingRfmCheckboxError) -type ([MessageType]::Error)
    }

    Write-Host ([StatusCheckMessages]::checkUserProvidedPackageUrl)
    $re = "(?smi)^\s*Package URL\s*\:\s*https\:\/\/chocolatey\.org\/packages\/([^\s\r\n]+)"
    if (!(Compare-Body @compareData -re $re)) {
        Write-Host ([StatusMessages]::userNotProvidedPackageUrl)
        $re = "(?smi)^\s*(Package URL)\s*:[^\r\n]*" # We want to replace the whole line
        if ((Compare-Body @compareData -re $re) -and $validationData.packageFound) {
            Update-ValidationBody -issueData $issueData -validationData $validationData -replacement $re, "`${1}: https://chocolatey.org/packages/$($validationData.packageName)"
        }
        else {
            Write-WarningMessage ([WarningMessages]::templateMissingPackageUrlAndNoPackageMatchesTitle)
            Update-StatusLabel -validationData $validationData -label ([StatusLabels]::incompleteRequest)
            Add-ValidationMessage -validationData $validationData -message ([ValidationMessages]::packageUrlMissingError) -type ([MessageType]::Error)
        }
    }

    Write-Host ([StatusCheckMessages]::checkUserProvidedPackageSourceUrl)
    $re = "(?smi)^\s*Package source URL\s*\:\s*(https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*))"
    if (!(Compare-Body @compareData -re $re)) {
        Write-Host ([StatusMessages]::userNotProvidedPackageSourceUrl)
        $re = "(?smi)^\s*(Package source URL)\s*:[^\r\n]*"
        if ((Compare-Body @compareData -re $re) -and $validationData.packageSourceUrl) {
            Write-Host ([StatusMessages]::packageSourceUrlFound)
            Update-ValidationBody -issueData $issueData -validationData $validationData -replacement $re, "`${1}: $($validationData.packageSourceUrl)"
        }
        else {
            Update-StatusLabel -validationData $validationData -label ([StatusLabels]::triageRequest)
            Add-ValidationMessage -validationData $validationData -message ([ValidationMessages]::packageSourceUrlMissingNotice) -type ([MessageType]::Warning)
        }
    }

    if ($currentMaintainer) {
        return Get-CurrentMaintainerValidationResult @PSBoundParameters
    }
    else {
        return Get-CommunityMaintainerValidationResults @PSBoundParameters
    }
}
