<#
.SYNOPSIS
    Gets a single issue
.DESCRIPTION
    Gets a single issue that matches the specified issue number in the
    specified repository, or by using the specified issue url.
.PARAMETER issueNumber
    The issue number of the issue to get
.PARAMETER issueUrl
    The api url to the issue to get
.PARAMETER repository
    The repository where the issue is located in
.OUTPUTS
    The found issue data
#>
function Get-Issue() {
    [OutputType([IssueData])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "number")]
        [int]$issueNumber,
        [Parameter(Mandatory = $true, ParameterSetName = "url")]
        [uri]$issueUrl,
        [Parameter(Mandatory = $true, ParameterSetName = "number")]
        [string]$repository,

        [string]$githubToken = $env:GITHUB_TOKEN
    )

    if ($issueUrl) {
        $response = Invoke-Api -url $issueUrl -githubToken $githubToken
    }
    else {

        $apiUrls = Get-ApiUrls

        if (!$apiUrls.issues_url) {
            Get-RepositoryData -repository $repository -githubToken $githubToken | Out-Null
        }

        $response = Invoke-Api -url $apiUrls.issues_url -parameters @{ number = $issueNumber } -githubToken $githubToken
    }

    $result = [IssueData]::new()

    $result.assignees = $response.assignees | ForEach-Object login
    $result.body = $response.body
    $result.html_url = $response.html_url
    $result.id = $response.id
    $result.labels = $response.labels | ForEach-Object name
    $result.number = $response.number
    $result.state = $response.state
    $result.title = $response.title
    $result.url = $response.url
    $result.userLogin = $response.user.login

    return $result
}
