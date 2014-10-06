Write-Host 'My Profile'

#region Add-Path
function Add-Path {
  <#
    .SYNOPSIS
      Adds a Directory to the Current Path
    .DESCRIPTION
      Add a directory to the current path.  This is useful for 
      temporary changes to the path or, when run from your 
      profile, for adjusting the path within your powershell 
      prompt.
    .EXAMPLE
      Add-Path -Directory "C:\Program Files\Notepad++"
    .PARAMETER Directory
      The name of the directory to add to the current path.
  #>

  [CmdletBinding()]
  param (
    [Parameter(
      Mandatory=$True,
      ValueFromPipeline=$True,
      ValueFromPipelineByPropertyName=$True,
      HelpMessage='What directory would you like to add?')]
    [Alias('dir')]
    [string[]]$Directory
  )

  PROCESS {
    $Path = $env:PATH.Split(';')

    foreach ($dir in $Directory) {
      if ($Path -contains $dir) {
        Write-Verbose "$dir is already present in PATH"
      } else {
        if (-not (Test-Path $dir)) {
          Write-Verbose "$dir does not exist in the filesystem"
        } else {
          $Path += $dir
        }
      }
    }

    $env:PATH = [String]::Join(';', $Path)
  }
}
#endregion

#region Get-App
##################################################################################################
## Example Usage:
##    Get-App Notepad
##       Finds notepad.exe using Get-Command
##    Get-App pbrush
##       Finds mspaint.exe using the "App Paths" registry key
##    &(Get-App WinWord)
##       Finds, and launches, Word (if it's installed) using the "App Paths" registry key
##################################################################################################
## Revision History
## 1.0 - initial release
##################################################################################################
function Get-App 
{
   param( [string]$cmd )
   $eap = $ErrorActionPreference
   $ErrorActionPreference = "SilentlyContinue"
   $AppPaths = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths"

   if ($cmd -eq '')
   {
        Get-ChildItem $AppPaths | %{$_.ToString()} | Split-Path -Leaf
   }
   else
   {
       Get-Command $cmd
       if(!$?) {
          if(!(Test-Path $AppPaths\$cmd)) {
             $cmd = [IO.Path]::GetFileNameWithoutExtension($cmd)
             if(!(Test-Path $AppPaths\$cmd)){
                $cmd += ".exe"
             }
          }
          if(Test-Path $AppPaths\$cmd) {
             Get-Command (Get-ItemProperty $AppPaths\$cmd)."(default)"
          }
       }
    }
}
#endregion

$profileCmdletPath = Join-Path $PSScriptRoot 'Cmdlets'
if (Test-Path $profileCmdletPath)
{
    Add-Path -Directory $profileCmdletPath
}

#New-Alias npp (Get-App notepad++.exe).path
#New-Alias devenv (Get-App devenv.exe).path
function show-path {($env:Path).split(';') | ?{$_ -ne '' -and $_ -ne '.'}}

# C:\Users\cfoley\AppData\Local\GitHub\shell.ps1


# Load posh-git example profile
# . 'C:\Users\cfoley\tools\posh-git-master\profile.example.ps1'

