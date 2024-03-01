<#
.SYNOPSIS
    Removes a single comment from the github repository.
.PARAMETER commentId
    The unique identifier of the comment to remove
.PARAMETER repository
    The repository where the comment is located
.OUTPUTS
    $null
#>
function Remove-Comment() {
    [OutputType($null)]
    param(
        [Parameter(Mandatory = $true)]
        [long]$commentId,
        [Parameter(Mandatory = $true)]
        [string]$repository,

        [string]$githubToken = $env:GITHUB_TOKEN
    )

    $apiUrls = Get-ApiUrls -githubToken $githubToken

    if (!$apiUrls.issue_comment_url) {
        Get-RepositoryData -repository $repository -githubToken $githubToken | Out-Null
    }

    Invoke-Api -url $apiUrls.issue_comment_url -parameters @{ number = $commentId } -method "DELETE" -githubToken $githubToken | Out-Null
}
