Properties {
    $OutputDirectory = "$PSScriptRoot/Build"
    $SrcDirectory = "$PSScriptRoot/Src"
}

Task 'default' -Depends clean, build

Task 'clean' {
    if (Test-Path $OutputDirectory) {
        Remove-Item $OutputDirectory -Recurse -Force
    }
}

Task 'build' {
    New-Item $OutputDirectory -ItemType Directory -ErrorAction SilentlyContinue > $null

    ## Copy manifest
    Copy-Item "$SrcDirectory/ObjectHelp.psd1" -Destination $OutputDirectory -Force

    ## Build module
    $ModuleContent = Get-Content "$SrcDirectory/ObjectHelp.psm1"
    foreach ($script in (Get-ChildItem $SrcDirectory -Include *.ps1 -Recurse)) {
        $ModuleContent += Get-Content $script.FullName
    }
    Set-Content "$OutputDirectory/ObjectHelp.psm1" -Value $ModuleContent -Encoding UTF8 -Force
}