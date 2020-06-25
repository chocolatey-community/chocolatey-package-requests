<#
.SYNOPSIS
    Updates a single comment on github.
.DESCRIPTION
    Updates the comment on github that have the
    unique identifier specified.
.PARAMETER commentId
    The unique identifier of the comment to update
.PARAMETER repository
    The repository the comment is located in
.PARAMETER commentBody
    The new body of the comment
.OUTPUTS
    Returns the updated comment
#>
function Update-Comment {
    [OutputType([CommentData])]
    param(
        [Parameter(Mandatory = $true)]
        [int]$commentId,
        [Parameter(Mandatory = $true)]
        [string]$repository,
        [Parameter(Mandatory = $true)]
        [string]$commentBody,

        [string]$githubToken = $env:GITHUB_TOKEN,

        [Parameter(ValueFromRemainingArguments = $true)]
        [Object[]] $ignoredArguments
    )

    $apiUrls = Get-ApiUrls

    if (!$apiUrls.issue_comment_url) {
        Get-RepositoryData -repository $repository -githubToken $githubToken | Out-Null
    }

    $arguments = @{
        url         = $apiUrls.issue_comment_url
        method      = "PATCH"
        githubToken = $githubToken
        parameters  = @{
            number = $commentId
        }
        content     = @{
            body = $commentBody
        }
    }

    $response = Invoke-Api @arguments

    $result = [CommentData]::new()
    $result.body = $response.body
    $result.html_url = $response.html_url
    $result.id = $response.id
    $result.issue_url = $response.issue_url
    $result.url = $response.url
    $result.userLogin = $response.user.login
    return $result
}
