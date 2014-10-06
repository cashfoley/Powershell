param ([switch]$WhatIf)

$FullNamesList = @"
MEDASSETS\aakinrem
MEDASSETS\AMehta
MEDASSETS\ArAli
MEDASSETS\asajjala
MEDASSETS\cabradley
MEDASSETS\lemartin
MEDASSETS\mfaili
MEDASSETS\mmonica
MEDASSETS\nwarne
MEDASSETS\rsingh
MEDASSETS\rviswana
MEDASSETS\twitte
"@

$tfsCollectionUrl = 'http://scmtfs.medassets.com:8080/tfs/scmtech'
#$tfsCollectionUrl = 'http://scmtfs.medassets.com:8080/tfs/sandbox'
$groupName = '[SPEND]\EDI Integrations Planning'

function AddUser($userName)
{
    if ($WhatIf)
    {
        write-host "TFSSecurity /g+ ""$groupName"" /collection:$tfsCollectionUrl n:$userName"
    }
    else
    {
        TFSSecurity /g+ "$groupName" /collection:$tfsCollectionUrl n:$userName
    }
}
$FullNames = $FullNamesList -split "[\r\n]" | ?{$_} 

foreach ($FullName in $FullNames)
{
    $names = $FullName -split " "
    if ($names.Count -eq 1)
    {
        AddUser -userName ("{0}" -f  $names[0].Trim())
    }
    elseif ($names.count -eq 2)
    {
        $userName = "medassets\{0}{1}" -f  $names[0][0], $names[1].Trim()
        # AddUser -userName $userName
    }
    else
    {
        "'{0}' - Not Added" -f $FullName
    }
}

