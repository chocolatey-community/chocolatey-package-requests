<#
.SYNOPSIS
    Submits a comment when running locally, stores the comment on github actions
.DESCRIPTION
    Small helper function for storing comments to be used later when running on
    github action, or just submit the comment as is when running locally.
.PARAMETER issueNumber
    The issue number to use in the request
.PARAMETER commentBody
    The actualy comment to submit/store when calling this function
#>
function Invoke-Commenting {
    param(
        [Parameter(Mandatory = $true)]
        [int]$issueNumber,
        [Parameter(Mandatory = $true)]
        [string]$repository,
        [Parameter(Mandatory = $true)]
        $commentBody
    )

    if (Test-Path Env:\GITHUB_ACTIONS) {
        $comment = ""
        if (Test-Path "$PSScriptRoot/../../../comment.txt") {
            $comment = Get-Content -Encoding utf8NoBOM -Path $comment
        }

        $comment = "$comment`n$commentBody"
        Write-Host "Storing comment text for using is github actions later..."
        $comment | Out-File "$PSScriptRoot/../../../comment.txt" -Encoding utf8NoBOM
    }
    else {
        Submit-Comment -issueNumber $issueNumber -repository $repository -commentBody $commentBody
    }
}
