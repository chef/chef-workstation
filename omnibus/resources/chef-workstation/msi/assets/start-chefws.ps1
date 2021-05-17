Try {
  $conemulocation = "$env:programfiles\ConEmu\Conemu64.exe"
  # We don't want the current path to affect which "chef shell-init powershell" we run, so we need to set the PATH to include the current omnibus.
  $chefws_bin = (split-path $MyInvocation.MyCommand.Definition -Parent)
  $chefwsinit = '"$env:PATH = ''' + $chefws_bin + ';'' + $env:PATH; $env:CHEFWS_ENV_FIX = 1; chef shell-init powershell | out-string | iex; Import-Module chef -DisableNameChecking"'
  $chefwsgreeting = "echo 'PowerShell $($PSVersionTable.psversion.tostring()) ($([System.Environment]::OSVersion.VersionString))';write-host -foregroundcolor darkyellow 'Ohai, welcome to Chef Workstation!`n'"
  $chefwscommand = "$chefwsinit;$chefwsgreeting"
  $chefwstitle = "Administrator: Chef Workstation ($env:username)"

  if ( test-path $conemulocation )
  {
      start-process $conemulocation -verb open -argumentlist '/title',"`"$chefwstitle`"",'/cmd','powershell.exe','-noexit','-command',$chefwscommand
  }
  else
  {
      start-process powershell.exe -verb open -argumentlist '-noexit','-command',"$chefwscommand; (get-host).ui.rawui.windowtitle = '$chefwstitle'"
  }
}
Catch
{
  sleep 10
  Throw
}
