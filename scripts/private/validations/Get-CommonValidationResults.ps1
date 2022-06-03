<#
.SYNOPSIS
    Validates the current request using common rules
.PARAMETER issueData
    The issue data for the current request
.PARAMETER validationData
    The validation data storage for the current request
#>
function Get-CommonValidationResults() {
    param(
        [Parameter(Mandatory = $true)]
        [IssueData]$issueData,
        [Parameter(Mandatory = $true)]
        [ValidationData]$validationData
    )

    $packageName = $issueData.title -replace "^[^\-:]*[-:]\s*(.+)$", "`$1"
    $packageName = ($packageName -replace " ", "-").ToLowerInvariant()
    $requestType = ($issueData.title -replace "^(RF[MP])\s*[-:].*", "`$1").ToUpperInvariant()
    $title = "{0} - {1}" -f $requestType, $packageName

    if ($requestType.Length -ne 3 -or ($requestType -notmatch "^RF[PM]$")) {
        Write-WarningMessage ([WarningMessages]::userNotSpecifiedCorrectRequestTitle)
        Update-StatusLabel -validationData $validationData -label ([StatusLabels]::incompleteRequest)
        Add-ValidationMessage -validationData $validationData -message ([ValidationMessages]::useCorrectTitleError) -type ([MessageType]::Error)
        return $false
    }
    if ($issueData.title -cne $title) {
        $validationData.newTitle = $title
    }
    $validationData.isNewPackageRequest = $requestType -eq "RFP"
    $validationData.packageName = $packageName

    if (!$issueData.body) {
        Write-WarningMessage ([WarningMessages]::userRequestedIssueWithEmptyBody)
        Update-StatusLabel -validationData $validationData -label ([StatusLabels]::incompleteRequest)
        $templatesDirectory = "$PSScriptRoot/../../../.github/ISSUE_TEMPLATE"
        if ($validationData.isNewPackageRequest) {
            $templateContent = Get-Content -Path "$templatesDirectory/mMaintainerRequest.md" -Encoding utf8NoBOM | Select-Object -Skip 4 | Join-String -Separator "`n"
        }
        else {
            $templateContent = Get-Content -Path "$templatesDirectory/kPackageRequest.md" -Encoding utf8NoBOM | Select-Object -Skip 4 | Join-String -Separator "`n"
        }

        $validationData.newbody = $templateContent

        Add-ValidationMessage -validationData $validationData -message ([ValidationMessages]::userRequestedIssueWithEmptyBodyError) -type ([MessageType]::Error)

        return $false
    }

    $possiblePackageNames = @($validationData.packageName)
    $noDashPackageName = $validationData.packageName -replace '-',''

    if ($noDashPackageName -ne $validationData.packageName) {
        $possiblePackageNames += @($noDashPackageName)
    }

    $result = $true

    foreach ($packageName in $possiblePackageNames) {
        try {
            Write-Host ([StatusCheckMessages]::checkPackageExistOnChocolatey -f $packageName)
            $chocolateyPage = Invoke-WebRequest -Uri ("https://community.chocolatey.org/packages/{0}" -f $packageName) -UseBasicParsing
            $validationData.packageFound

            Write-Host ([StatusMessages]::packageFoundOnChocolatey)

            $allListedLinks = $chocolateyPage.Links | Where-Object { $_.href -match "^\/packages\/$($packageName)\/" -and $_.href -notmatch "Contact(Admins|Owners)$|ReportAbuse$" }
            if ($validationData.isNewPackageRequest) {
                Write-WarningMessage ([WarningMessages]::userRequestedNewPackage -f $packageName)
                Update-StatusLabel -validationData $validationData -label ([StatusLabels]::incompleteRequest)
                if (!$allListedLinks) {
                    $newMsg = [ValidationMessages]::packageExistsUnlistedError
                }
                else {
                    $newMsg = [ValidationMessages]::packageExistsError
                }
                Add-ValidationMessage -validationData $validationData -message ($newMsg -f $packageName) -type ([MessageType]::Error)

                $result = $false
                break
            }

            $validationData.packageFound = $true
            $validationData.packageSourceUrl = $chocolateyPage.Links | Where-Object title -match "^See the package source\." | Select-Object -First 1 -ExpandProperty href
            $validationData.packageMaintainers = $chocolateyPage.Links | Where-Object { $_.href -match "\/profiles\/" -and $_.title } | Select-Object -ExpandProperty title -Unique | Sort-Object
            $result = $true
            break
        }
        catch {
            $validationData.packageFound = $false
            if (!$validationData.isNewPackageRequest) {
                Write-WarningMessage ([WarningMessages]::userRequestedNewMaintainer)
                Update-StatusLabel -validationData $validationData -label ([StatusLabels]::incompleteRequest)
                Add-ValidationMessage -validationData $validationData -message ([ValidationMessages]::packageNotFoundError -f $packageName) -type ([MessageType]::Error)

                $result = $false
            }
        }
    }

    return $result
}
