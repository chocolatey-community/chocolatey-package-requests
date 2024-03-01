enum IssueState {
    None
    Open
    Closed
}

class IssueData {
    [long]$id;
    [string]$url;
    [string]$html_url;
    [long]$number;
    [IssueState]$state;
    [string]$title;
    [string]$body;
    [string]$userLogin;
    [string[]]$labels;
    [string[]]$assignees;
}
