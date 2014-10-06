$CollectionUrlParam = 'http://scmtfs.medassets.com:8080/tfs/Sandbox'
$ProjectName = 'WfxSandbox'
$AreaPath = 'WfxSandbox'
$WorkItemType = 'Task'

Add-Type -AssemblyName "Microsoft.TeamFoundation.Client, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a",
                       "Microsoft.TeamFoundation.Common, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a",
                       "Microsoft.TeamFoundation, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a",
                       "Microsoft.TeamFoundation.WorkItemTracking.Client, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a"

$tfs = [Microsoft.TeamFoundation.Client.TfsTeamProjectCollectionFactory]::GetTeamProjectCollection($CollectionUrlParam)
$WIT = $tfs.GetService([Microsoft.TeamFoundation.WorkItemTracking.Client.WorkItemStore])

 $query = "
 SELECT [System.Id], [System.WorkItemType], [System.Title], [System.AssignedTo], [System.State], [System.Tags]
   FROM WorkItems 
  WHERE [System.TeamProject] = 'WfxSandbox'  
    AND [System.WorkItemType] = 'Task'  
    AND [System.State] = 'Done'  
    AND [System.AreaPath] UNDER 'WfxSandbox'  
    AND [Microsoft.VSTS.Common.ClosedDate] = '' 
  ORDER BY [System.Id]"
 
 $workItems = $WIT.Query($query)
 
 [datetime] $NewClosedDate = '1/1/1990'
 $idx = 0
 foreach ($workItem in $workItems)
 {
    $idx += 1
    $workItem.PartialOpen()
    $workItem.Fields['Closed Date'].Value = $NewClosedDate
    "{0,6} {1,-10} {2,-20} {3}" -f $idx, $workItem.Fields['ID'].Value, $workItem.Fields['Assigned To'].Value , $workItem.Fields['Closed Date'].Value
    $workItem.Save()
    $workItem.Close()
 }
