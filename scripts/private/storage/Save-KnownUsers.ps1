function Save-KnownUsers {
    param (
        [Parameter(Mandatory = $true)]
        [UserData[]]$users,
        [string]$usersJsonFile = "$PSScriptRoot/../../users.json"
    )

    # This is just to ensure that users with missing information aren't stored
    $users = $users | ? { $_.github -and $_.choco }

    $users | Sort-Object -Property choco, github | ConvertTo-Json -AsArray | Out-File $usersJsonFile -Encoding utf8NoBOM
}
