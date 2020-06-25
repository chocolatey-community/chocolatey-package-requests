function Get-KnownUser {
    param (
        [Parameter(Mandatory = $true, ParameterSetName = "github")]
        [string]$github,
        [Parameter(Mandatory = $true, ParameterSetName = "choco")]
        [string]$chocolatey
    )

    $allUsers = Get-KnownUsers

    return $allUsers | ? {
        ($github -and $_.github -eq $github) `
            -or ($chocolatey -and $_.choco -eq $chocolatey)
    } | select -First 1
}
