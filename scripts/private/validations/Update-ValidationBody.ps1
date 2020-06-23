<#
.SYNOPSIS
    Updates the body for the current validation request.
.PARAMETER issueData
    The issue data for the current request
.PARAMETER validationData
    The validation data storage for the current request
.PARAMETER replacement
    The regex replacement to perform on the body
#>
function Update-ValidationBody {
    param(
        [Parameter(Mandatory = $true)]
        [IssueData]$issueData,
        [Parameter(Mandatory = $true)]
        [ValidationData]$validationData,
        #[Parameter(Mandatory = $true)]
        [string[]]$replacement
    )

    $body = $null

    if ($validationData.newBody) {
        $body = $validationData.newBody -replace $replacement
    }
    else {
        $body = $issueData.body -replace $replacement
    }

    if ($body -cne $issueData.body) {
        $validationData.newBody = $body
    }
}
