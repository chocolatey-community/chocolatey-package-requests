<#
.SYNOPSIS
    Validates the current request as a new package request
.PARAMETER issueData
    The issue data for the current request
.PARAMETER validationData
    The validation data storage for the current request
#>
function Get-NewPackageValidationResult() {
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

    $downloadUrl = $null

    Write-Host ([StatusCheckMessages]::checkingUserMarkedChocolateySearched)
    $re = "\[x\]\s*The package I am req"
    if (!(Compare-Body @compareData -re $re)) {
        Update-StatusLabel -validationData $validationData -label ([StatusLabels]::incompleteRequest)
        Add-ValidationMessage -validationData $validationData -message ([ValidationMessages]::chocolateySearchNotMarkedError) -type ([MessageType]::Error)
    }

    Write-Host ([StatusCheckMessages]::checkingUserMarkedDownloadUrlPublic)
    $re = "\[x\]\s*The download URL is public"
    if (!(Compare-Body @compareData -re $re)) {
        Update-StatusLabel -validationData $validationData -label ([StatusLabels]::incompleteRequest)
        Add-ValidationMessage -validationData $validationData -message ([ValidationMessages]::downloadUrlPublicMarkedError) -type ([MessageType]::Error)
    }

    Write-Host ([StatusCheckMessages]::checkUserMarkedWithCorrectRFPTitle)
    $re = "(?i)\[[\sx]*\]\s*((?:The )?Issue title starts(?: with)? 'RFP)"
    if ((Compare-Body @compareData -re $re) -and ($issueData.title -match "^RFP" -or $validationData.newTitle -match "^RFP")) {
        Write-Host ([StatusMessages]::uncheckedRFPItemFound)
        Update-ValidationBody -issueData $issueData -validationData $validationData -replacement $re, "[x] `${1}"
    }
    else {
        Write-WarningMessage ([WarningMessages]::templateMissingRFPCheckbox)
        Update-StatusLabel -validationData $validationData -label ([StatusLabels]::incompleteRequest)
        Add-ValidationMessage -validationData $validationData -message ([ValidationMessages]::issueMissingRfpCheckboxError) -type ([MessageType]::Error)
    }

    Write-Host ([StatusCheckMessages]::checkingUserProvidedSoftwareProjectUrl)
    $re = "(?smi)Software project URL\s*\:[\s\r\n]*(https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*))"
    $m = Compare-Body @compareData -re $re
    if (!$m) {
        Update-StatusLabel -validationData $validationData -label ([StatusLabels]::incompleteRequest)
        Add-ValidationMessage -validationData $validationData -message ([ValidationMessages]::softwareProjectUrlError) -type ([MessageType]::Error)
    }

    Write-Host ([StatusCheckMessages]::checkingUserProvidedDirectDownloadUrl)
    $re = "(?smi)Direct download[^\:]+\:[\s\r\n]*(https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*))"
    $m = Compare-Body @compareData -re $re
    if (!$m) {
        Update-StatusLabel -validationData $validationData -label ([StatusLabels]::incompleteRequest)
        Add-ValidationMessage -validationData $validationData -message ([ValidationMessages]::softwareDirectDownloadError) -type ([MessageType]::Error)
    }
    else {
        $downloadUrl = $m[1]
    }

    Write-Host ([StatusCheckMessages]::checkingUserSearchedForOpenIssues)
    $re = "\[x\]\s*There is no open issue"
    if (!(Compare-Body @compareData -re $re)) {
        Update-StatusLabel -validationData $validationData -label ([StatusLabels]::incompleteRequest)
        Add-ValidationMessage -validationData $validationData -message ([ValidationMessages]::githubSearchNotMarkedError -f $validationData.repository, ($validationData.packageName -replace ' ', '%20')) -type ([MessageType]::Error)
    }

    try {
        if ($downloadUrl) {
            Write-Host ([StatusCheckMessages]::fileDownloadCheck)
            Get-RemoteFile -url $downloadUrl -filePath "$env:TEMP/software.tmp"

            Write-Host ([StatusCheckMessages]::fileDownloadCheck)
            $result = Test-ValidFile "$env:TEMP/software.tmp"

            if ($result -eq "missing") {
                Write-ErrorMessage ([ErrorMessages]::toolingMissing)
                return $false
            }
            else {
                if ($result.valid) {
                    $msg = ""
                    $msgType = [MessageType]::Info
                }
                else {
                    Write-WarningMessage ([WarningMessages]::fileValidationFailed)
                    $msg = [ValidationMessages]::fileValidationFailed
                    $validationData.newLabels += [StatusLabels]::upstreamBlocked
                    $msgType = [MessageType]::Warning
                }
                $msg += "`n<details>`n<summary>File Validation Output</summary>`n`n```````n"
                $result.output | % { $msg += "$_`n" }
                $msg += "```````n</details>"
                Add-ValidationMessage -validationData $validationData -message $msg -type $msgType
            }

            Remove-Item "$env:TEMP/software.tmp" -ea 0
        }
        else {
            Write-WarningMessage ([WarningMessages]::noDownloadUrlFound)
        }
    }
    catch {
        Write-WarningMessage ([WarningMessages]::downloadValidationFailed)
        Add-ValidationMessage -validationData $validationData -message ([ValidationMessages]::fileValidationMaintainerNotice) -type ([MessageType]::Info)
        $validationData.newLabels += [StatusLabels]::upstreamBlocked
    }

    return $true
}
