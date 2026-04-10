$libPath = "dist/main.lua"
$userPath = "Premium_Example.lua"
$outputPath = "FINAL_PRO_SPECTRE.lua"

if (Test-Path $libPath) {
    if (Test-Path $userPath) {
        $libContent = Get-Content $libPath -Raw
        $userContentRaw = Get-Content $userPath -Raw
        
        # Remove the first two lines containing the loader manually via regex to be safe
        $userContentMerged = $userContentRaw -replace '(?s)^.*?local Fluent = loadstring\(.*?\)\(\)\s*\n', ''
        
        $finalContent = "local Fluent = (function()`r`n" + $libContent + "`r`nend)()`r`n`r`n" + $userContentMerged
        
        Set-Content -Path $outputPath -Value $finalContent -Encoding utf8
        Write-Host "SUCCESS: FINAL_PRO_SPECTRE.lua created successfully!"
    } else {
        Write-Error "ERROR: Premium_Example.lua not found!"
    }
} else {
    Write-Error "ERROR: dist/main.lua not found!"
}
