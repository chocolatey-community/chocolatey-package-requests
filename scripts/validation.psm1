#requires -version "7.0"

$paths = "private", "public"
foreach ($path in $paths) {
    Get-ChildItem $PSScriptRoot\$path\*.ps1 -Recurse | ForEach-Object {
        Write-Verbose "Importing file $_"
        . $_
        if ($path -eq "public") {
            Write-Verbose "Exporting member $($_.BaseName)"
            Export-ModuleMember -Function $_.BaseName
        }
    }
}
