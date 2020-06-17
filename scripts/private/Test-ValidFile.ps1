<#
.SYNOPSIS
    Tests a downloaded file to see if it
    is a valid for the current request.
.PARAMETER filePath
    The path to the downloaded file
.OUTPUTS
    A hashtable containing the result
    of the check, and the output from trid.
#>
function Test-ValidFile {
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$filePath
    )

    if (!(Test-Path $filePath)) { return "missing" }
    if (!(Get-Command trid -ea 0)) { return "missing" }

    $result = @{}

    # First check if it as an gz file
    $output = trid $filePath
    $result["output"] = $output
    if ($output | Where-Object { $_ -match "100\.0%.*GZipped" }) {
        if (!(Get-Command 7z -ea 0)) { return "missing" }

        7z e $filePath
        $filePath = (Get-Item $filePath).BaseName
        $output = trid $filePath
        $result["output"] += $output
    }

    $supportedMatches = @("Executable"; "Windows Installer"; "Archive")

    $result["valid"] = $output | Where-Object {
        $line = $_
        $supportedMatches | Where-Object { $line -match $_ }
    }

    return $result
}
