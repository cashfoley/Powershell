#Set environment variables for Visual Studio Command Prompt
pushd 'c:\Program Files (x86)\Microsoft Visual Studio 12.0\VC'

cmd /c "vcvarsall.bat&set" |
    foreach {
      if ($_ -match "=") 
      {
        $v = $_.split("=")
        # Write-Host  $_
        set-item -force -path "ENV:\$($v[0])" -value "$($v[1])"
      }
    }

popd

write-host "`nVisual Studio 2013 Command Prompt variables set." -ForegroundColor Yellow
