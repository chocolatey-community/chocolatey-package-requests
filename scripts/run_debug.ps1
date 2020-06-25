Remove-Module validation -Force -ea 0
Import-Module "$PSScriptRoot\validation.psm1"

Update-IssueStatus -issueNumber 34 -repository "AdmiringWorm/chocolatey-package-requests"
