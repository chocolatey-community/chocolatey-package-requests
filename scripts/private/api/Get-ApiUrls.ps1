class ApiUrls {
    [string]$collaborators_url;
    [string]$issue_comment_url;
    [string]$issue_search_url;
    [string]$issues_url;
    [string]$permissions_url;
    [string]$repository_url;
}

$Script:apiUrls = $null

<#
.SYNOPSIS
    Gets the stored urls known during this session.
.DESCRIPTION
    This function gets the stored urls from the current session,
    or reached out to the github api to get the first basic urls.
.OUTPUTS
    A class holding the api urls.
#>
function Get-ApiUrls {
    [OutputType([ApiUrls])]
    param(
        [string]$githubToken = $env:GITHUB_TOKEN
    )

    if ($Script:apiUrls) {
        return $Script:apiUrls
    }

    $response = Invoke-Api -url "https://api.github.com" -githubToken $githubToken | Select-Object issue_search_url, repository_url

    $Script:apiUrls = [ApiUrls]::new()
    $Script:apiUrls.issue_search_url = $response.issue_search_url
    $Script:apiUrls.repository_url = $response.repository_url;

    return $Script:apiUrls
}
