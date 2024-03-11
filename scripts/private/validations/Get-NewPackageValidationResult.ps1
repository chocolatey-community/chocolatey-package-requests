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
    $re = "(?smi)Software project URL\s*\:[\s\r\n]*(https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,10}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*))"
    $m = Compare-Body @compareData -re $re
    if (!$m) {
        Update-StatusLabel -validationData $validationData -label ([StatusLabels]::incompleteRequest)
        Add-ValidationMessage -validationData $validationData -message ([ValidationMessages]::softwareProjectUrlError) -type ([MessageType]::Error)
    }

    Write-Host ([StatusCheckMessages]::checkingUserProvidedDirectDownloadUrl)
    $re = "(?smi)Direct download[^\:]+\:[\s\r\n]*(https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,10}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*))"
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

    $fileOutput = "$([System.IO.Path]::GetTempPath())software.tmp"

    try {
        if ($downloadUrl) {
            Write-Host ([StatusCheckMessages]::fileDownloadCheck)
            Get-RemoteFile -url $downloadUrl -filePath $fileOutput

            Write-Host ([StatusCheckMessages]::fileDownloadCheck)
            $result = Test-ValidFile $fileOutput

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

    if (Test-Path $fileOutput) {
        $results = Get-VirusTotalResults -filePath $fileOutput

        if ($results.Status -eq "NoApiKey" -or $results.Status -eq "NotFound") {
            Write-Host ([StatusMessages]::noVirusTotalStatusAvailable)
            Add-ValidationMessage -validationData $validationData -message ([validationMessages]::noVirusTotalResults) -type ([MessageType]::Info)
        }
        elseif ($results.Flagged -gt 0) {
            Add-ValidationMessage -validationData $validationData -message ([ValidationMessages]::virusTotalResultsCount -f $results.Flagged, $results.TotalCount, $results.Url) -type ([MessageType]::Info)
        }
        else {
            Add-ValidationMessage -validationData $validationData -message ([ValidationMessages]::virusTotalResultsNone -f $results.Url) -type ([MessageType]::Info)
        }

        Remove-Item $fileOutput -ea 0
    }

    return $true
}
