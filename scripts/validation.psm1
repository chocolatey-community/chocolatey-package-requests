#requires -version "7.0"

$paths = "private", "public"
foreach ($path in $paths) {
    Get-ChildItem $PSScriptRoot\$path\*.ps1 -Recurse | ForEach-Object {
        Write-Host "Importing file $_"
        . $_
        if ($path -eq "public") {
            Write-Host "Exporting member $($_.BaseName)"
            Export-ModuleMember -Function $_.BaseName
        }
    }
}
