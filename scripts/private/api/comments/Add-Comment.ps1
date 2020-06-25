<#
.SYNOPSIS
    Adds a completely new comment on github.
.PARAMETER issueNumber
    The issue number to add the new comment to.
.PARAMETER repository
    The repository that the issue is located in.
.PARAMETER commentBody
    The actual comment to submit to github.
.OUTPUTS
    Returns the created comment
#>
function Add-Comment {
    [OutputType([CommentData])]
    param (
        [Parameter(Mandatory = $true)]
        [int]$issueNumber,
        [Parameter(Mandatory = $true)]
        [string]$repository,
        [Parameter(Mandatory = $true)]
        [string]$commentBody,

        [string]$githubToken = $env:GITHUB_TOKEN,

        [Parameter(ValueFromRemainingArguments = $true)]
        [Object[]] $ignoredArguments
    )

    $apiUrls = Get-ApiUrls

    if (!$apiUrls.issues_url) {
        Get-RepositoryData -repository $repository -githubToken $githubToken | Out-Null
    }

    $arguments = @{
        url         = $apiUrls.issues_url
        method      = "POST"
        githubToken = $githubToken
        parameters  = @{
            number = "$issueNumber/comments"
        }
        content     = @{
            body = $commentBody
        }
    }

    return Invoke-Api @arguments
}
