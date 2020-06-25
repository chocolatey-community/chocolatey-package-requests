function Update-StatusComment {
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "issue")]
        [int]$issueNumber,
        [Parameter(Mandatory = $true, ParameterSetName = "comment")]
        [int]$commentId,
        [Parameter(Mandatory = $true)]
        [string]$packageName,
        [Parameter(Mandatory = $true)]
        [string]$repository,

        [PackageData[]]$statusData = $null,

        [Parameter(ValueFromRemainingArguments = $true)]
        [Object[]] $ignoredArguments = $null
    )

    $comment = "This comment is used to track the current status of this request.`n<!-- START PACKAGE LIST -->"

    if ($statusData -and $statusData.Count -gt 0) {
        $statusData | % {
            $firstVersion = $_.versions | select -First 1
            if ($firstVersion) {
                $comment = "$comment`n- [$($_.name)]($($firstVersion.url)) (Status: $($firstVersion.status), Listed: $($firstVersion.listed), Is New: $($firstVersion.isNew), Version: $($firstVersion.version))"
            }
            else {
                $comment = "$comment`n- **$($_.name)** (Status: Missing)"
            }
        }
    }
    else {
        $comment = "$comment`n- **$packageName** (Status: Missing)"
    }

    $comment = "$comment`n<!-- END PACKAGE LIST -->`n<!-- START STATUS DATA`n" `
        + ([Newtonsoft.Json.JsonConvert]::SerializeObject($statusData, [Newtonsoft.Json.Formatting]::Indented)) `
        + "`nEND STATUS DATA -->"

    $arguments = @{
        repository  = $repository
        commentBody = $comment
    }
    if ($commentId) {
        $arguments["commentId"] = $commentId
    }
    else {
        $arguments["issueNumber"] = $issueNumber
    }

    Submit-Comment @arguments
}
