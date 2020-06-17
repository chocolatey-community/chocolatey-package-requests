<#
.SYNOPSIS
    Search the specified repository for issues
.DESCRIPTION
    Searches the specified repository for issues
    that matches the specified query
.PARAMETER query
    The query to use when searching for issues.
.PARAMETER repository
    The repository to execute the search inside.
.OUTPUTS
    An array of issue datas matching the search query
#>
function Search-Issues {
    [OutputType([IssueData[]])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$query,
        [Parameter(Mandatory = $true)]
        [string]$repository,

        [string]$githubToken = $env:GITHUB_TOKEN
    )

    $apiUrls = Get-ApiUrls

    if (!$apiUrls.issue_search_url) {
        Get-RepositoryData -repository $repository -githubToken $githubToken | Out-Null
    }

    $result = Invoke-Api -url $apiUrls.issue_search_url -parameters @{ query = $query }

    return $result.items | % {
        $item = [IssueData]::new()
        $item.assignees = $_.assignes | % login
        $item.body = $_.body
        $item.html_url = $_.html_url
        $item.id = $_.id
        $item.labels = $_.labels | % name
        $item.number = $_.number
        $item.state = $_.state
        $item.title = $_.title
        $item.url = $_.url
        $item.userLogin = $_.user.login
        $item
    }
}
