<#
 .SYNOPSIS
    Deploys a template to Azure

 .DESCRIPTION
    Deploys an Azure Resource Manager template

 .PARAMETER subscriptionId
    The subscription id where the template will be deployed.

 .PARAMETER resourceGroupName
    The resource group where the template will be deployed. Can be the name of an existing or a new resource group.

 .PARAMETER resourceGroupLocation
    Optional, a resource group location. If specified, will try to create a new resource group in this location. If not specified, assumes resource group is existing.

 .PARAMETER deploymentName
    The deployment name.

 .PARAMETER templateFilePath
    Optional, path to the template file. Defaults to template.json.

 .PARAMETER parametersFilePath
    Optional, path to the parameters file. Defaults to parameters.json. If file is not found, will prompt for parameter values based on template.
#>

param(
 [Parameter(Mandatory=$True)]
 [string]
 $subscriptionId,

 [Parameter(Mandatory=$True)]
 [string]
 $location,

 [Parameter(Mandatory=$True)]
 [string]
 $name,

 [Parameter(Mandatory=$True)]
 [string]
 $adminPasswordPlain,

 [Parameter(Mandatory=$True)]
 [pscredential]
 $mailCredential,

 [Parameter(Mandatory=$True)]
 [string]
 $mailFrom,

 [Parameter(Mandatory=$True)]
 [string]
 $mailTo,

 [Parameter(Mandatory=$True)]
 [string]
 $personName,

 [Parameter(Mandatory=$False)]
 [switch]
 $initial = $False

)

<#
.SYNOPSIS
    Registers RPs
#>
Function RegisterRP {
    Param(
        [string]$ResourceProviderNamespace
    )

    Write-Host "Registering resource provider '$ResourceProviderNamespace'";
    Register-AzResourceProvider -ProviderNamespace $ResourceProviderNamespace;
}

# copied from https://stackoverflow.com/a/34383413 with a minimal change
Function ConvertPSObjectToHashtable
{
    param (
        [Parameter(ValueFromPipeline)]
        $InputObject,

        [switch]
        $NoRecurse
    )

    process
    {
        if ($null -eq $InputObject) { return $null }

        if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string])
        {
            $collection = @(
                foreach ($object in $InputObject) { ConvertPSObjectToHashtable $object }
            )
            
            Write-Output -NoEnumerate $collection
        }
        elseif ($InputObject -is [psobject])
        {
            $hash = @{}

            foreach ($property in $InputObject.PSObject.Properties)
            {
                $hash[$property.Name] = ConvertPSObjectToHashtable $property.Value
            }

            $hash
        }
        else
        {
            $InputObject
        }
    }
}

#******************************************************************************
# Script body
# Execution begins here
#******************************************************************************
$ErrorActionPreference = "Stop"

$adminPassword = (ConvertTo-SecureString -String $adminPasswordPlain -AsPlainText -Force)

if ($initial) {
    # sign in
    Write-Host "Logging in...";
    Login-AzAccount

    # select subscription
    Select-AzSubscription -SubscriptionID $subscriptionId;

    # Register RPs
    $resourceProviders = @("microsoft.network","microsoft.compute","microsoft.devtestlab","microsoft.resources");
    if($resourceProviders.length) {
        Write-Host "Registering resource providers"
        foreach($resourceProvider in $resourceProviders) {
            RegisterRP($resourceProvider);
        }
    }
}

#Create or check for existing resource group
$resourceGroup = Get-AzResourceGroup -Name $name -ErrorAction SilentlyContinue
if(!$resourceGroup)
{
    Write-Host "Resource group '$name' does not exist. Creating resource group '$name' in location '$location'";
    New-AzResourceGroup -Name $name -Location $location
}
else{
    Write-Host "Using existing resource group '$name'";
}

# Start the deployment
Write-Host "Starting big deployment...";
New-AzResourceGroupDeployment -ResourceGroupName $name -Name "$name-big-deployment" -TemplateFile (Join-Path $PSScriptRoot "big\template.json") -TemplateParameterFile (Join-Path $PSScriptRoot "\big\parameters.json") -location $location -adminPassword $adminPassword -dnsLabelPrefix "td19-$name-big" -AsJob
Write-Host "Starting small deployment...";
New-AzResourceGroupDeployment -ResourceGroupName $name -Name "$name-small-deployment" -TemplateFile (Join-Path $PSScriptRoot "small\template.json") -TemplateParameterFile (Join-Path $PSScriptRoot "small\parameters.json") -location $location -adminPassword $adminPassword -dnsLabelPrefix "td19-$name-small" -AsJob

# Send mail
$smtpServer = "smtp.office365.com"
$smtpPort = "587"
$body = "Hello $personName,<br />&nbsp;<br/>"
$body += "welcome to the `"Docker on Windows 101 and Business Central on Docker`" workshop at NAV TechDays! Please use the following connection information to access your VMs through a Remote Desktop connection:<br />&nbsp;<br/>"
$body += "Big VM (host): computer name td19-$name-big.$location.cloudapp.azure.com, user name \TechDaysAdmin, password $adminPasswordPlain<br/>"
$body += "Small VM (host): computer name td19-$name-small.$location.cloudapp.azure.com, user name \TechDaysAdmin, password $adminPasswordPlain<br/>&nbsp;<br />"
$body += "Please note that it might take up to 20 minutes until the VMs are available<br/>&nbsp;<br />"
$body += "Have fun,<br />Tobias"
$mailParam = @{
    To = $mailTo
    From = $mailFrom
    Subject = "Access information for your NAV TechDays workshop VM"
    Body = $body
    SmtpServer = $smtpServer
    Port = $smtpPort
    Credential = $mailCredential
}

Send-MailMessage @mailParam -UseSsl -BodyAsHtml