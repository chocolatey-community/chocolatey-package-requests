<#
.SYNOPSIS
    Simple helper file for downloading files from a remote location.
.PARAMETER url
    The remote location to use while downloading the file.
.PARAMETER filePath
    The Path to where the file should be saved.
#>
function Get-RemoteFile {
    param(
        [Parameter(Mandatory = $true)]
        [uri]$url,
        [Parameter(Mandatory = $true)]
        $filePath
    )

    try {
        if (!(Get-Command "Get-Webfile" -ea 0)) {
            $chocoImported = $true
            Import-Module "$env:chocolateyInstall/helpers/chocolateyInstaller.psm1"
        }

        Get-Webfile -Url $url -FileName $filePath
    }
    catch {
        throw $_
    }
    finally {
        if ($chocoImported) {
            Remove-Module "chocolateyInstaller" -ea 0
        }
    }
}
