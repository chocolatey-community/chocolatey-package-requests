class PermissionData {
    [string]$login;
    [bool]$readAccess;
    [bool]$writeAccess;
    [bool]$adminAccess;
}

<#
.SYNOPSIS
    Gets the permissions set for the specified login name
.PARAMETER login
    The login/username of the user to get the repository permissions for.
.PARAMETER repository
    The repository to use.
.PARAMETER githubToken
    The token to use for authenticated requests
.OUTPUTS
    Returns the available permissions for the user
#>
function Get-Permission {
    [OutputType([PermissionData])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$login,

        [Parameter(Mandatory = $true)]
        [string]$repository,

        [string]$githubToken = $env:GITHUB_TOKEN
    )

    $apiUrls = Get-ApiUrls

    if (!$apiUrls.permissions_url) {
        Get-RepositoryData -repository $repository -githubToken $githubToken | Out-Null
    }

    $response = Invoke-Api -url $apiUrls.permissions_url -parameters @{ collaborator = $login }

    $permissionData = [PermissionData]::new()

    if ($response) {
        $permissionData.login = $response.user.login
        $permissionData.adminAccess = $response.permission -eq 'admin'
        $permissionData.writeAccess = $permissionData.adminAccess -or $response.permission -eq 'write' -or $permissionData.permission -eq 'maintainer' # Maintainer is never returned, but maybe in the future
        $permissionData.readAccess = $permissionData.writeAccess -or $response.permission -eq 'read' -or $permissionData.permission -eq 'triage' # Triage is never returned, but maybe in the future
    }

    return $permissionData
}
