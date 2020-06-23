<#
.SYNOPSIS
    Disconnect stored chocolatey/github user.
.PARAMETER commentId
    The identifier of the comment that
    executed this request.
.PARAMETER repository
    The repository where this comment is located in.
#>
function Remove-UserConnection() {
    param(
        [Parameter(Mandatory = $true)]
        [int]$commentId,
        [string]$repository = $env:GITHUB_REPOSITORY
    )

    $commentData = Get-Comment -commentId $commentId -repository $repository
    $permissionData = Get-Permission -login $commentData.userLogin -repository $repository
    $issueNumber = Split-Path -Leaf $commentData.issue_url

    if (!$permissionData.readAccess) {
        # I assume the user is banned in this case
        Submit-Comment -issueNumber $issueNumber -repository $repository -commentBody ([PermissionMessages]::actionDenied -f $permissionData.login)
        return
    }

    $existingData = @()

    if (Test-Path "$PSScriptRoot/../users.json") {
        "Loading existing users"
        [array]$existingData = Get-Content -Raw -Encoding utf8NoBOM -Path "$PSScriptRoot/../users.json" | ConvertFrom-Json
    }

    if (!$existingData -or $existingData.Count -eq 0) {
        "No users available, exiting..."
        # Set us just ignore everything
        return
    }

    "Reiceved comment '$($commentData.body)'"

    $statusMessage = ""
    $throwError = $false

    $chocoUsers = @()
    $githubUsers = @()

    $commentData.body -split "\r?\n" | Select-String "^/(?:detach|remove user) (?:@(?<githubUser>[^\s\.\,]+)|(?<chocoUser>[a-z0-9_\.-]+))" -AllMatches | % Matches | % {
        if ($_.Groups["githubUser"].Success) {
            $requestedUser = $_.Groups["githubUser"].Value
            "User requested to remove the github user '@$requestedUser'"
            if ($requestedUser -ne $permissionData.login -and !$permissionData.writeAccess) {
                $statusMessage = [PermissionMessages]::userRemoveDenied -f $permissionData.login
                $throwError = $true
                "Request was denied..."
                return
            }
            else {
                $githubUsers += @($_.Groups["githubUser"].Value)
                "Request was accepted."
            }
        }
        elseif ($_.Groups["chocoUser"].Success) {
            $requestedUser = $_.Groups["chocoUser"].Value
            "User requested to remove the chocolatey user '$requestedUser'"
            $data = $existingData | ? choco -eq $requestedUser
            if ($data -and $data.github -ne $permissionData.login -and !$permissionData.writeAccess) {
                $statusMessage = [PermissionMessages]::userRemoveDenied -f $permissionData.login
                $throwError = $true
                "Request was denied..."
                return
            }
            else {
                $chocoUsers += $requestedUser
                "Request was accepted..."
            }
        }
    }

    if ($commentData.body -match "(?smi)^\/remove user\s*([^@a-z0-9_\.-]|$)") {
        "Requested user requested to remove themself as known user..."
        $githubUsers += @($commentData.userLogin)
    }

    $chocoUsers | % {
        if (!$throwError) {
            "Removing chocolatey user '$_'"
            $existingData = $existingData | ? choco -ne $_
            $msg = [StatusMessages]::chocolateyUserDisconnected -f $_
            $statusMessage = "$statusMessage`n$msg"
        }
    }
    $githubUsers | % {
        if (!$throwError) {
            "Removing github user '@$_'"
            $existingData = $existingData | ? github -ne $_
            $msg = [StatusMessages]::githubUserDisconnected -f $_
            $statusMessage = "$statusMessage`n$msg"
        }
    }

    if ($throwError) {
        Submit-Comment -issueNumber $issueNumber -repository $repository -commentBody $statusMessage
    }
    elseif ($statusMessage) {
        "Saving new users data"
        $existingData | Sort-Object -Property choco, github | ConvertTo-Json -AsArray | Out-File "$PSScriptRoot/../users.json" -Encoding utf8NoBOM
        Invoke-Commenting -issueNumber $issueNumber -repository $repository -commentBody $statusMessage
    }
}
