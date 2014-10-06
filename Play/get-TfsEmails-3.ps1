function Get-TFSGroupMembership
{
    Param([string] [string]$GroupName, $CollectionUrlParam="http://scmtfs.medassets.com:8080/tfs/SCMTech")
    
    
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
 
    $tfs = [Microsoft.TeamFoundation.Client.TfsTeamProjectCollectionFactory]::GetTeamProjectCollection($CollectionUrlParam)
 
    $cssService = $tfs.GetService("Microsoft.TeamFoundation.Server.ICommonStructureService3")   

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
    $ReadIdentityOptions = [Microsoft.TeamFoundation.Framework.Common.ReadIdentityOptions]::TrueSid

    $CatalogName = $tfs.CatalogNode.Resource.DisplayName

    $ProjectName = [regex]::Match($GroupName,"\[(.*?)\]").Groups[1].Value
    if ($ProjectName -eq "")
    {
        Throw "Group Name must contain Project - '[project]\groupname'"
        exit 1
    }

    try
    {
        $GroupIdentity = $idService.ListApplicationGroups($ProjectName, $ReadIdentityOptions) | ?{$_.DisplayName -eq $GroupName}
    }
    catch
    {
        Write-Error ("Error looking up Project '{0}' in Collection '{1}'" -f $ProjectName, $CollectionUrlParam)
        Throw $_
        exit 1
    }

     if ($GroupIdentity -eq $null)
     {
        Throw ("Group '{0}' in Project '{1}' could not be found" -f $GroupName,$ProjectName)
        exit 1
     }

     $ids = list_identities  $GroupIdentity.Descriptor 
     $ids | sort -Unique UniqueName | %{$_.GetProperty('Mail')} | ?{$_} | %{$_ + ';'} 
 exit

    $scope = [regex]::Match( $GroupName )

    exit

    $ids = @()
    foreach($teamProject in $projectList)
    {       
        foreach($group in $idService.ListApplicationGroups($teamProject.Name, $ReadIdentityOptions))
        {
            $ids += list_identities  $group.Descriptor 
        }
    }

    $ids | sort -Unique UniqueName | %{$_.GetProperty('Mail')} | ?{$_} | %{$_ + ';'} 
}

Get-TFSGroupMembership -GroupName "[Sandbox_1]\MDM" -CollectionUrlParam "http://scmtfs.medassets.com:8080/tfs/Sandbox"

