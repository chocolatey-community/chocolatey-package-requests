<#
.SYNOPSIS
    Invokes a single call to the github api using the specified url format.
.DESCRIPTION
    Invokes a single call to the github api using the specified url format.
    This function also allows the url to be formatted with the specified parameters.
    This function also makes sure that the content (if specified) is correctly serialized
    to json using Newtonsoft.
.PARAMETER url
    The url format to use when calling github.
.PARAMETER parameters
    The parameters to use when formatting the url.
.PARAMETER method
    The method to use when calling the githb api (Typically, GET, POST, PATCH and DELETE)
    (Defaults to Get)
.PARAMETER content
    The content to submit to the github api (like a comment for instance)
.PARAMETER githubToken
    The token to use for authenticated requests (Recommended to be used)
    (Defaults to $env:GITHUB_TOKEN)
.OUTPUTS
    The result of the request.
#>
function Invoke-Api {
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$url,
        [hashtable]$parameters = @{},
        [string]$method = "Get",
        [hashtable]$content = $null,
        [string]$githubToken = $env:GITHUB_TOKEN
    )

    $headers = @{}
    if ($githubToken) {
        Write-Verbose "Using Authenticated github reques"
        $headers["Authorization"] = "token " + $githubToken
    }

    $formattedUrl = Format-Url $url $parameters

    $arguments = @{
        Uri             = $formattedUrl
        Method          = $method
        Headers         = $headers
        UseBasicParsing = $true
    }

    if ($content) {
        # Workaround since the API don't like a line to end with a space + colon (json parsing error on github)
        $json = [Newtonsoft.Json.JsonConvert]::SerializeObject($content) -replace "\s+:(\\[rn]|$)", ":`${1}"
        $arguments["Body"] = $json
        $arguments["ContentType"] = "application/json"
    }

    return Invoke-RestMethod @arguments
}
