enum MessageType {
    None
    Error
    Warning
    Info # This is for maintainers, not for the requester
}

class ValidationMessage {
    [string]$message;
    [MessageType]$type;
}

class ValidationData {
    [string]$newTitle;
    [string[]]$newLabels;
    [string]$newBody;
    [bool]$packageFound;
    [string]$packageName;
    [string]$packageSourceUrl;
    [string[]]$packageMaintainers;
    [System.Collections.Generic.List[ValidationMessage]]$messages;
    [bool]$isNewPackageRequest;
    [string]$repository;
}
