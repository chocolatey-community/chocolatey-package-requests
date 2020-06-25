<#
.SYNOPSIS
    Updates a single issue
.DESCRIPTION
    Updates a single issue with either the matching issue
    number and located in the specified repository, or using
    the full api url for issues.
.PARAMETER issueNumber
    The issue number of the issue to update.
.PARAMETER repository
    The repository where the issue is located in.
.PARAMETER issueurl
    The full api url for the issue
.PARAMETER title
    The new title of the issue
.PARAMETER description
    The new description/body of the issue
.PARAMETER assignees
    The people that should be assigned to this issue
.PARAMETER labels
    The labels that should be set on the issue (will override existing labels)
.PARAMETER state
    The state of the issue (typically Open or closed)
.PARAMETER githubToken
    The token to use for authenticated requests
.OUTPUTS
    Returns the updated issue data
#>
function Update-Issue {
    [OutputType([IssueData])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "number")]
        [int]$issueNumber,
        [Parameter(Mandatory = $true, ParameterSetName = "number")]
        [string]$repository,

        [Parameter(Mandatory = $true, ParameterSetName = "url")]
        [string]$issueUrl,

        [string]$title,
        [string]$description,
        [string[]]$assignees,
        [string[]]$labels,
        [IssueState]$state = 'None',

        [string]$githubToken = $env:GITHUB_TOKEN
    )

    if (!$title -and !$description -and !$assignees -and !$labels) {
        throw "Not valid data was used to update the issue. A title, description, assignees or labels is required."
    }

    if ($issueUrl) {
        $existingIssue = Get-Issue -issueUrl $issueUrl -githubToken $githubToken
    }
    else {
        $existingIssue = Get-Issue -issueNumber $issueNumber -repository $repository -githubToken $githubToken
    }

    $content = @{}

    if ($title) {
        $content['title'] = $title
    }
    if ($description) {
        $content['body'] = $description
    }
    if ($assignees) {
        $content['assignees'] = $assignees
    }
    if ($labels) {
        $content['labels'] = $labels
    }
    if ($state -ne 'None' -and $state -ne $existingIssue.state) {
        $content['state'] = $state
    }

    $response = Invoke-Api -url $existingIssue.url -parameters @{ number = $issueNumber } -method "PATCH" -content $content -githubToken $githubToken

    $result = [IssueData]::new()

    $result.assignees = $response.assigees | ForEach-Object login
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
