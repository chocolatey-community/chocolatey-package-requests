<#
.SYNOPSIS
    Add a single validation message to the validation data storage.
.PARAMETER validationData
    The validation data storage to add the message to
.PARAMETER message
    The validation message to add
.PARAMETER type
    The type of the validation message
#>
function Add-ValidationMessage {
    param(
        [Parameter(Mandatory = $true)]
        [ValidationData]$validationData,
        [Parameter(Mandatory = $true)]
        [string]$message,
        [Parameter(Mandatory = $true)]
        [MessageType]$type
    )

    $validationMessage = [ValidationMessage]::new()
    $validationMessage.message = $message
    $validationMessage.type = $type

    if (!$validationData.messages) {
        $validationData.messages = [System.Collections.Generic.List[ValidationMessage]]::new()
    }

    $validationData.messages.Add($validationMessage)
}
