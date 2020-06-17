<#
.SYNOPSIS
    Small helper to update or add a new comment
.PARAMETER issueNumber
    The issue number to create a new comment on
.PARAMETER commentId
    The unique identifier of the comment to update
.PARAMETER repository
    The repository where the issue/comment is located in
.PARAMETER commentBody
    The actualy comment to add/update
.PARAMETER githubToken
    The api token to use for authenticated requests
.OUTPUTS
    The updated/added comment data
#>
function Submit-Comment {
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "New Issue")]
        [int]$issueNumber,
        [Parameter(Mandatory = $true, ParameterSetName = "Update Issue")]
        [int]$commentId,
        [Parameter(Mandatory = $true)]
        [string]$repository,
        [Parameter(Mandatory = $true)]
        [string]$commentBody,

        [string]$githubToken = $env:GITHUB_TOKEN
    )

    if ($commentId) {
        return Update-Comment -commentId $commentId -repository $repository -commentBody $commentBody -githubToken $githubToken
    }
    else {
        return Add-Comment -issueNumber $issueNumber -repository $repository -commentBody $commentBody -githubToken $githubToken
    }
}
