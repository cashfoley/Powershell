function Get-TFSGroupMembership
{
    Param([string] $CollectionUrlParam,
          [string[]] $Projects,
          [switch] $ShowEmptyGroups)
 
    function list_identities ($tfsIdentity)
    {
        $queryOption = ([Microsoft.TeamFoundation.Framework.Common.MembershipQuery]::Direct)
        $readIdentityOptions = ([Microsoft.TeamFoundation.Framework.Common.ReadIdentityOptions]::TrueSid)

        $identities = $idService.ReadIdentities($tfsIdentity, $queryOption, $readIdentityOptions)
       
        foreach($id in $identities)
        {
            if ($id.IsContainer)
            {
                if ($id.Members.Count -gt 0)
                {
                    list_identities $id.Members 
                }
            }
            else
            {
                $id
            } 
        }
    }
 
 
    # load the required dlls
 
    Add-Type -AssemblyName "Microsoft.TeamFoundation.Client, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a",
                           "Microsoft.TeamFoundation.Common, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a",
                           "Microsoft.TeamFoundation, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a"
 
    $projectList = @()
 
    if ($CollectionUrlParam)
    {
        #if collection is passed then use it and select all projects
        $tfs = [Microsoft.TeamFoundation.Client.TfsTeamProjectCollectionFactory]::GetTeamProjectCollection($CollectionUrlParam)
 
        $cssService = $tfs.GetService("Microsoft.TeamFoundation.Server.ICommonStructureService3")   
   
        if ($Projects)
        {
            #validate project names
            foreach ($p in $Projects)
            {
                try
                {
                    $projectList += $cssService.GetProjectFromName($p)
                }
                catch
                {
                    Write-Error "Invalid project name: $p"
                    exit
                }
            }       
        }
        else
        {
            $projectList = $cssService.ListAllProjects()
        }
    }
    else
    {
        #if no collection specified, open project picker to select it via gui
        $picker = New-Object Microsoft.TeamFoundation.Client.TeamProjectPicker([Microsoft.TeamFoundation.Client.TeamProjectPickerMode]::MultiProject, $false)
        $dialogResult = $picker.ShowDialog()
        if ($dialogResult -ne "OK")
        {
            exit
        }
 
        $tfs = $picker.SelectedTeamProjectCollection
        $projectList = $picker.SelectedProjects
    }
 
 
    try
    {
        $tfs.EnsureAuthenticated()
    }
    catch
    {
        Write-Error "Error occurred trying to connect to project collection: $_ "
        exit 1
    }
 
    $idService = $tfs.GetService("Microsoft.TeamFoundation.Framework.Client.IIdentityManagementService")
 
    $ids = @()
    foreach($teamProject in $projectList)
    {       
        foreach($group in $idService.ListApplicationGroups($teamProject.Name,
                                                           [Microsoft.TeamFoundation.Framework.Common.ReadIdentityOptions]::TrueSid))
        {
            $ids += list_identities  $group.Descriptor 
        }
    }

    $ids | sort -Unique UniqueName | %{$_.GetProperty('Mail')} | ?{$_} | %{$_ + ';'} 
}

Get-TFSGroupMembership

