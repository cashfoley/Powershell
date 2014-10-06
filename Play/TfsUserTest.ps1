cls
$CollectionUrlParam = 'http://scmtfs.medassets.com:8080/tfs/SCMTech'
#$TfsGroup = '[Spend]\Enrollment'
$targetGroup = '[SPEND]\Enrollment'
$targetProject = 'SPEND'

Add-Type -AssemblyName "Microsoft.TeamFoundation.Client, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a",
                       "Microsoft.TeamFoundation.Common, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a",
                       "Microsoft.TeamFoundation, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a"
 

$tfs = [Microsoft.TeamFoundation.Client.TfsTeamProjectCollectionFactory]::GetTeamProjectCollection($CollectionUrlParam)
$max_call_depth = 30

try
{
    $tfs.EnsureAuthenticated()
}
catch
{
    Write-Error "Error occurred trying to connect to project collection: $_ "
    exit 1
}
 
$cssService = $tfs.GetService("Microsoft.TeamFoundation.Server.ICommonStructureService3")   
$idService = $tfs.GetService("Microsoft.TeamFoundation.Framework.Client.IIdentityManagementService")
$gssService = $tfs.GetService("Microsoft.TeamFoundation.Server.IGroupSecurityService")

function Get-UsersFromTfsGroup ($queryOption,$tfsIdentity,$readIdentityOptions)
{
    $identities = $idService.ReadIdentities($tfsIdentity, $queryOption, $readIdentityOptions)
       
    foreach($id in $identities)
    {
        if ($id.IsContainer)
        {
            if ($id.Members.Count -gt 0)
            {
                Get-UsersFromTfsGroup $queryOption $id.Members $readIdentityOptions
            }
        }
        else
        {
            foreach ($memberGroup in $id.MemberOf)
            {
                if ($memberGroup.IdentityType -eq 'Microsoft.TeamFoundation.Identity')
                {
                    $id
                }
            }
        } 
    }
}



$queryOption = [Microsoft.TeamFoundation.Framework.Common.MembershipQuery]::Direct
$readIdentityOptions = [Microsoft.TeamFoundation.Framework.Common.ReadIdentityOptions]::TrueSid

#$CollectionGroups = $idService.ListApplicationGroups($null,[Microsoft.TeamFoundation.Framework.Common.ReadIdentityOptions]::TrueSid)
#$validUserGroupIdentity = $CollectionGroups | ?{$_.DisplayName -eq $TfsGroup}

$ProjectGroups = $idService.ListApplicationGroups($targetProject,[Microsoft.TeamFoundation.Framework.Common.ReadIdentityOptions]::TrueSid)
$targetGroupIdentity = $ProjectGroups | ?{$_.DisplayName -eq $targetGroup}

if ($validUserGroupIdentity -eq $null)
{
    Write-Error "$TfsGroup not found"
}
elseif ($targetGroupIdentity -eq $null)
{
    Write-Error "$targetGroup not found"
}
else
{
    #$CollectionUsers = Get-UsersFromTfsGroup -queryOption $queryOption -tfsIdentity $validUserGroupIdentity.Descriptor -readIdentityOptions $readIdentityOptions | 
    #    Sort-Object UniqueName -Unique | ?{$_.UniqueName -ne 'TEAM FOUNDATION\Anonymous'}

    $ProjectUsers = Get-UsersFromTfsGroup -queryOption $queryOption -tfsIdentity $targetGroupIdentity.Descriptor -readIdentityOptions $readIdentityOptions
    
    #foreach ($CollectionUser in $CollectionUsers)
    #{
    #    if (!($ProjectUsers | Where-Object -Property UniqueName -EQ $CollectionUser.UniqueName))
    #    {
    #        $userName = '"' + $CollectionUser.UniqueName + '"'
    #        "Add $userName"
    #        #$gssService.AddMemberToApplicationGroup($targetGroupIdentity.Descriptor, $CollectionUser.Descriptor)
    #        . "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\tfsSecurity" /collection:$CollectionUrlParam /g+ $targetGroup n:$userName
    #    }
    #}
     
}
