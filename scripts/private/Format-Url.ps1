<#
.SYNOPSIS
    Formats the specified url using the specified parameters hashtable
.PARAMETER url
    The url format to use when formatting the result url
.PARAMETER parameters
    The parameters to use when replacing tokens in the url.
.OUTPUTS
    The formatted Url
#>
function Format-Url() {
    param(
        [Parameter(Mandatory = $true)]
        [string]$url,
        [hashtable]$parameters = @{ }
    )

    $newUrl = ""

    $insideQuote = $false
    $lastIndex = 0 
    $char = ''
    $checkComma = $true
    while ($lastIndex -ge 0) {
        if (!$insideQuote -and ($i = $url.IndexOf('{', $lastIndex)) -gt $lastIndex) {
            $newUrl += $url.Substring($lastIndex, $i - $lastIndex)
            $insideQuote = $true
            $c = $url[$i + 1]
            if ($c -eq '?' -or $c -eq '+' -or $c -eq '/' -or $c -eq '&') {
                $char = $c
                $i++
            }
            else { $char = '' }
            $lastIndex = $i + 1
            $checkComma = $true
        }
        elseif ($insideQuote) { 
            $name = ''
            if ($checkComma -and ($i = $url.IndexOf(',', $lastIndex)) -ge $lastIndex) {
                $name = $url.Substring($lastIndex, $i - $lastIndex)
            }
            elseif (($i = $url.IndexOf('}', $lastIndex)) -ge $lastIndex) {
                $name = $url.Substring($lastIndex, $i - $lastIndex)
                $insideQuote = $false
            }

            if ($name -notmatch "^[a-z0-9_]+$") {
                $checkComma = $false
            }
            else {
                if ($parameters.ContainsKey($name)) {
                    $newUrl += $char + $parameters[$name]
                    if ($char -eq '?') { $char = '&' }
                }
                
                if ($i -eq -1) { break; } 
                $lastIndex = $i + 1
            }
        }
        else {
            break
        }
    }

    if ($lastIndex -ge 0) {
        $newUrl += $url.Substring($lastIndex)
    }

    return $newUrl
}