function Compare-Body {
    param (
        [Parameter(Mandatory = $true)]
        [IssueData]$issueData,
        [Parameter(Mandatory = $true)]
        [ValidationData]$validationData,
        [Parameter(Mandatory = $true)]
        [string]$re
    )

    if ($validationData.newBody) {
        $res = $validationData.newBody -match $re | Out-Null
    }
    else {
        $res = $issueData.body -match $re
    }

    if ($res) {
        return $Matches
    }
}
