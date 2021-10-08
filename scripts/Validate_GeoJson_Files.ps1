
# ==============================
# Test Validity of GeoJson files
# ============================== 
$pathP = "C:\tmp\json"; 
$files = Get-ChildItem  $pathP\*.json 
$output = $files | ForEach-Object {
                        $content = Get-Content $_.FullName
                        $valid = $content | Test-Json
                        "file: " + $_.FullName + "   valid: " + $valid
                        }
$output | Out-File "C:\tmp\json\powershell_scripts\Validate_GeoJson_files.txt"