
$CollectionUrlParam = 'http://scmtfs.medassets.com:8080/tfs/Sandbox'
$teamProject = "All1"

Add-Type -AssemblyName "Microsoft.TeamFoundation.Client, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a",
                       "Microsoft.TeamFoundation.Common, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a",
                       "Microsoft.TeamFoundation, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a",
                       "Microsoft.TeamFoundation.Build.Client, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a"

function AddFakeBuildDefinition($buildServer, $teamProject, $definitionName)
{
    try
    {
        return $buildServer.GetBuildDefinition($teamProject, $definitionName);
    }
    catch 
    {
       
    }

    # Use the first build controller as the controller for these builds
    $serviceHost = $buildServer.CreateBuildServiceHost("fakemachine", "http://noservice:8888/");
    $serviceHost.Save();

    $controller = $serviceHost.CreateBuildController("fakeController");
    $controller.Save();

    # Get the Upgrade template to use as the process template
    $upgradeProcessTemplate = [Microsoft.TeamFoundation.Build.Client.ProcessTemplateType]::Upgrade
    $processTemplateArray = @($upgradeProcessTemplate)
    $processTemplate = ($buildServer.QueryProcessTemplates($teamProject, $processTemplateArray))[0];

    $definition = $buildServer.CreateBuildDefinition($teamProject);
    $definition.Name = $definitionName;
    $definition.ContinuousIntegrationType = [Microsoft.TeamFoundation.Build.Client.ContinuousIntegrationType]::None
    $definition.BuildController = $controller;
    $definition.DefaultDropLocation = '\\MySharedMachine\drops\';
    $definition.Description = "Fake build definition used to create fake builds.";
    $definition.Enabled = $false;
    $definition.Workspace.AddMapping("$/", "c:\\fake", [Microsoft.TeamFoundation.Build.Client.WorkspaceMappingType]::Map);
    $definition.Process = $processTemplate;
    $definition.Save();

    return $definition;
}


$collection = [Microsoft.TeamFoundation.Client.TfsTeamProjectCollectionFactory]::GetTeamProjectCollection($CollectionUrlParam)
$buildServer = $collection.GetService([Microsoft.TeamFoundation.Build.Client.IBuildServer])

$buildDefinition = AddFakeBuildDefinition $buildServer $teamProject "FakeDefinition2"

$buildDefinition

exit




