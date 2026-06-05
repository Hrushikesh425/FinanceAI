$files = Get-ChildItem -Path "e:\FinanceAI\lib" -Recurse -Filter "*.dart"
foreach ($file in $files) {
    $content = Get-Content $file.FullName
    $newContent = $content -replace "import '\.\./\.\./\.\./core/", "import 'package:finance_ai/core/"
    $newContent = $newContent -replace "import '\.\./\.\./core/", "import 'package:finance_ai/core/"
    $newContent = $newContent -replace "import '\.\./core/", "import 'package:finance_ai/core/"
    Set-Content -Path $file.FullName -Value $newContent
}
