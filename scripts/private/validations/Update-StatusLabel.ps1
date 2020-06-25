<#
.SYNOPSIS
    Updates the status label for the current request
.DESCRIPTION
    Updates the status label for the current request
    and stores it to the specified validation data storage.
.PARAMETER validationData
    The validation data storage to use
.PARAMETER label
    The status label to update to
#>
function Update-StatusLabel {
    param(
        [Parameter(Mandatory = $true)]
        [ValidationData]$validationData,
        [Parameter(Mandatory = $true)]
        [string]$label
    )

    if (!$validationData.newLabels -or $validationData.newLabels.Count -eq 0) {
        $validationData.newLabels = @($label)
    }

    $existingStatusLabel = $validationData.newLabels | ? { $_ -match "^Status:" }

    if ($existingStatusLabel -ne [StatusLabels]::incompleteRequest) {
        $validationData.newLabels = ($validationData.newLabels | ? { $_ -ne $existingStatusLabel }) + $label
    }
}
