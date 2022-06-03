<#
.SYNOPSIS
    Connect chocolatey user together with a github user.
.PARAMETER commentId
    The identifier of the comment that
    executed this request.
.PARAMETER repository
    The repository where this comment is located in.
#>
function New-UserConnection {
    param(
        [Parameter(Mandatory = $true)]
        [int]$commentId,
        [string]$repository = $env:GITHUB_REPOSITORY
    )

    $commentData = Get-Comment -commentId $commentId -repository $repository
    $permissionData = Get-Permission -login $commentData.userLogin -repository $repository
    $issueNumber = Split-Path -Leaf $commentData.issue_url

    $statusMsgs = ""
    if (!$permissionData.readAccess) {
        # I assume the user is banned in this case
        Submit-Comment -issueNumber $issueNumber -repository $repository -commentBody ([PermissionMessages]::actionDenied -f $permmisionData.login)
        return
    }

    [array]$userData = $commentData.body -split "\r?\n" | Select-String "^/attach (?:@(?<githubUser>[^\s\.\,]+)[\.\,\s]*(?<chocoUser>[a-z0-9_\.-]+)|(?<chocoUser>[a-z0-9_\.-]+)[^@]+@(?<githubUser>[^\s\n\r\.\,]+))" -AllMatches | ForEach-Object Matches | ForEach-Object {
        $githubUser = $_.Groups["githubUser"]
        if ($githubUser.Value -ne $permissionData.login -and !$permissionData.writeAccess) {
            $statusMsgs = [PermissionMessages]::userAddDenied -f $permissionData.login
            return
        }

        $chocoUser = $_.Groups["chocoUser"]
        return @{
            github = $githubUser.Value
            choco  = $chocoUser.Value
            type   = 'attached'
        }
    }

    if ($statusMsgs) {
        Submit-Comment -issueNumber $issueNumber -repository $repository -commentBody $statusMsgs
        return
    }

    $userData += $commentData.body -split "\r?\n" | Select-String "^/(?:attach|confirm)\s+([a-z0-9_\.-]+)\s*([\n\r]|$)" -AllMatches | ForEach-Object Matches | ForEach-Object {
        return @{
            github = $permissionData.login
            choco  = $_.Groups[1].Value
            type   = if ($_.ToString().StartsWith('/confirm')) { "confirmed" } else { "attached" }
        }
    } | Select-Object -First 1

    if ($userData.Count -eq 0) {
        $statusMsgs = [ErrorMessages]::invalidCommand -f $permissionData.login
        Write-WarningMessage ([ErrorMessages]::invalidCommandException)
        Submit-Comment -issueNumber $issueNumber -repository $repository -commentBody $statusMsgs
        return
    }

    $chocoUrlFormat = "https://community.chocolatey.org/profiles/{0}"


    # TODO validate that current user have permissions to do this command (need write or triage access), unless the user have confirmed
    # the chocolatey username
    $existingData = @()

    if (Test-Path "$PSScriptRoot/../users.json") {
        [array]$existingData = Get-Content -Raw -Encoding utf8NoBOM -Path "$PSScriptRoot/../users.json" | ConvertFrom-Json
        $existingData | ForEach-Object {
            if ($userData | Where-Object github -eq $_.github) {
                $msg = [WarningMessages]::githubUserConnected -f $_.github
                $statusMsgs = "${statusMsgs}`n$msg"
                Write-WarningMessage $msg
                $userData = $userData | Where-Object github -ne $_.github
            }
            if ($userData | Where-Object choco -eq $_.choco) {
                $msg = [WarningMessages]::chocolateyUserConnected -f $_.choco
                $statusMsgs = "${statusMsgs}`n$msg"
                Write-WarningMessage $msg
                $userData = $userData | Where-Object choco -ne $_.choco
            }
        }
    }

    $userData = $userData | Where-Object {
        try {
            Invoke-WebRequest ($chocoUrlFormat -f $_.choco) -UseBasicParsing
            return $true
        }
        catch {
            $msg = [WarningMessages]::chocolateyUserMissing -f $_.choco
            Write-WarningMessage $msg
            $statusMsgs = "${statusMsgs}`n$msg"
            return $false
        }
    } | Sort-Object -Property choco, github

    $userData + $existingData | Select-Object -Property choco, github | Sort-Object -Property choco, github | ConvertTo-Json -AsArray | Out-File "$PSScriptRoot/../users.json" -Encoding utf8NoBOM

    $userData | ForEach-Object {
        $msg = ""
        if ($_.type -eq 'confirmed') {
            $msg = [StatusMessages]::chocolateyUserConfirmed -f $_.github, $_.choco
        }
        else {
            $msg = [StatusMessages]::chocolateyUserConnected -f $_.choco, $_.github
        }
        $statusMsgs = "$statusMsgs`n$msg"
        $msg
    }

    Invoke-Commenting -issueNumber $issueNumber -repository $repository -commentBody $statusMsgs
}
