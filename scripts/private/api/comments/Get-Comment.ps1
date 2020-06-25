<#
.SYNOPSIS
    Gets a single comment on github
.DESCRIPTION
    Get a single comment on github by either using the
    specified commentId parameter, or using content matching
    to see which comment has the a matching body.
.PARAMETER commentId
    The unique identifier of the comment to get.
.PARAMETER issueNumber
    The issue number that the comment is located in.
.PARAMETER contentMatch
    The regex that should match the body of the comment
    to return.
.PARAMETER repository
    The repository where the comment are located in.
.OUTPUTS
    The found comment.
.NOTES
    Only the first match of the comment is returned
    when content matching is used.
#>
function Get-Comment {
    [OutputType([CommentData])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "known comment")]
        [int]$commentId,
        [Parameter(Mandatory = $true, ParameterSetName = "matching content")]
        [int]$issueNumber,
        [Parameter(Mandatory = $true, ParameterSetName = "matching content")]
        [string]$contentMatch,
        [Parameter(Mandatory = $true)]
        [string]$repository,

        [string]$githubToken = $env:GITHUB_TOKEN,

        [Parameter(ValueFromRemainingArguments = $true)]
        [Object[]] $ignoredArguments
    )

    $apiUrls = Get-ApiUrls

    if (!$apiUrls.issue_comment_url) {
        Get-RepositoryData -repository $repository -githubToken $githubToken | Out-Null
    }

    if ($issueNumber) {
        $comments = Invoke-Api -url $apiUrls.issues_url -parameters @{ number = "$issueNumber/comments" }

        return $comments | Where-Object { $_.body -match $contentMatch } | Select-Object -First 1
    }

    $response = Invoke-Api -url $apiUrls.issue_comment_url -parameters @{ number = $commentId }

    $result = [CommentData]::new()
    $result.body = $response.body
    $result.html_url = $response.html_url
    $result.id = $response.id
    $result.issue_url = $response.issue_url
    $result.url = $response.url
    $result.userLogin = $response.user.login

    return $result
}
