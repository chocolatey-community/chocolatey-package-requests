enum IssueState {
    None
    Open
    Closed
}

class IssueData {
    [int]$id;
    [string]$url;
    [string]$html_url;
    [int]$number;
    [IssueState]$state;
    [string]$title;
    [string]$body;
    [string]$userLogin;
    [string[]]$labels;
    [string[]]$assignees;
}
