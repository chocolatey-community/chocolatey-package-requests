class RepositoryData {
    [int]$id;
    [string]$name;
    [string]$full_name;
    [string]$html_url;
    [string]$description;
    [string]$url;
    [string]$collaborators_url;
    [string]$issue_comment_url;
    [string]$issues_url;
}

<#
.SYNOPSIS
    Gets information about a single repository
.PARAMETER repoOwner
    The owner of the repository
.PARAMETER repoName
    The name of the repository
.PARAMETER repository
    The full name of the repository (owner/name)
.PARAMETER githubToken
    The api token to use for authenticated requests
.OUTPUTS
    The gathered repository data information
#>
function Get-RepositoryData {
    [OutputType([RepositoryData])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "repo+owner")]
        [string]$repoOwner,

        [Parameter(Mandatory = $true, ParameterSetName = "repo+owner")]
        [string]$repoName,

        [Parameter(Mandatory = $true, ParameterSetName = "repository")]
        [string]$repository,

        [string]$githubToken = $env:GITHUB_TOKEN
    )

    $apiUrls = Get-ApiUrls -githubToken $githubToken

    if ($repository) {
        $repoSplits = $repository -split '\/'
        $repoOwner = $repoSplits[0]
        $repoName = $repoSplits[1]
    }

    [RepositoryData]$repositoryData = Invoke-Api -url $apiUrls.repository_url -parameters @{ owner = $repoOwner; repo = $repoName } | Select-Object -Property id, name, full_name, html_url, description, url, collaborators_url, issue_comment_url, issues_url

    if (!$apiUrls.collaborators_url) {
        $apiUrls.collaborators_url = $repositoryData.collaborators_url
        $apiUrls.permissions_url = Format-Url -url $apiUrls.collaborators_url -parameters @{ collaborator = "{collaborator}/permission" }
    }
    if (!$apiUrls.issue_comment_url) {
        $apiUrls.issue_comment_url = $repositoryData.issue_comment_url
    }
    if (!$apiUrls.issues_url) {
        $apiUrls.issues_url = $repositoryData.issues_url
    }

    return $repositoryData
}
