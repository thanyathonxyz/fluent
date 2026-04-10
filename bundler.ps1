$lib = Get-Content 'dist\main.lua' -Raw
$script = Get-Content 'Premium_Example.lua' -Raw

# Remove the local loader from the example script since we are bundling it
$script = $script -replace 'local Fluent = loadstring\(readfile\(.*?\)\)\(\)', '-- Library bundled below'

$final = "local Fluent = (function()`r`n" + $lib + "`r`nend)()`r`n" + $script

$final | Out-File -FilePath 'FINAL_PRO_SPECTRE.lua' -Encoding utf8
