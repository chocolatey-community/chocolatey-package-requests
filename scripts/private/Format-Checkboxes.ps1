function Format-Checkboxes() {
    param (
        [Parameter(Mandatory = $true)]
        [IssueData]$issueData,
        [Parameter(Mandatory = $true)]
        [ValidationData]$validationData
    )

    $re = "\[(\s+x|x\s+|\s+x\s+)\]"
    if ($validationData.newBody) {
        if ($validationData.newBody -match $re) {
            Update-ValidationBody @PSBoundParameters -replacement $re, "[x]"
        }
    }
    elseif ($issueData.body -match $re) {
        Update-ValidationBody @PSBoundParameters -replacement $re, "[x]"
    }
}
