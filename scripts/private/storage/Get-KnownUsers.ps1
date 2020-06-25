class UserData {
    [string]$choco
    [string]$github
}

function Get-KnownUsers {
    param (
        [string]$usersJsonFile = "$PSScriptRoot/../../users.json"
    )

    if (!(Test-Path $usersJsonFile)) {
        return [UserData[]]::new()
    }

    [UserData[]]$users = Get-Content $usersJsonFile -Encoding utf8NoBOM | ConvertFrom-Json

    return $users
}
