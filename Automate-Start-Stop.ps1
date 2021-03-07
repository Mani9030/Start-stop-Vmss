#######Start VMs

$connectionName = "AzureRunAsConnection"

# Get the connection "AzureRunAsConnection "
$servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

"Logging in to Azure..."
Add-AzureRmAccount `
    -ServicePrincipal `
    -TenantId $servicePrincipalConnection.TenantId `
    -ApplicationId $servicePrincipalConnection.ApplicationId `
    -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 

#Getting the list of Resource groups with "Prprod" Prefix
$_preprodRG = Get-AzureRmResourceGroup | Where ResourceGroupName -like mc_tbs-rg-si-nld-preprod-*-hlf_tbs-si-nld-preprod-hlf-*-aks-01_southindia            

echo $_preprodRG

#devRG represents here all resources under Preprod
$devRG = @()
$devRG += $_preprodRG 
$dev_count=$devRG.count
echo $dev_count
#Initialzing Variables
$VM_LIST=@()
$VM_LIST_ALL = {}

#Fetch the List of VM in above mentioned RG
for($i=0;$i-le $dev_count-1;$i++)
{ 

$VM_LIST_ALL= Get-AzureRmVM -ResourceGroupName $devRG[$i].ResourceGroupName
if( $VM_LIST_ALL -eq $NULL)
    {
        continue;
    }
else
    {
        [array]$VM_LIST=[array]$VM_LIST+@(Get-AzureRmVM -ResourceGroupName $devRG[$i].ResourceGroupName)
    }
}
#Write-Output $VM_LIST

<#Write-Output $VM_LIST.Count#>
#$vmPowerstate=@()

#Start Virtual Machines which are in Stopped State
for($i=0; $i-le ($VM_LIST.Count)-1;$i++)
{
    $VmStatus = Get-AzureRmVm -Name $VM_LIST.Name[$i] -ResourceGroupName $VM_LIST.ResourceGroupName[$i] -Status
    #[array]$vmPowerstate =[array]$vmPowerstate +@($vmStatus.PowerState)
    $vmPowerState = $VmStatus.Statuses.DisplayStatus[1]
    Write-Output $vmPowerstate
    echo $VM_LIST.Name[$i]

    	if($vmPowerState -eq "VM deallocated")
        {
            Write-Output ("Starting virtual machine"+ $VM_LIST.Name[$i])
            $startStatus = Start-AzureRmVm -Name $VM_LIST.Name[$i] -ResourceGroupName $VM_LIST.ResourceGroupName[$i]
            if($startStatus.Status -eq "Succeeded" -or $startStatus.IsSuccessStatusCode -eq "True")
            {
                Write-Output ("Successfully started virtual machine"+ $VM_LIST.Name[$i])
            }
            else
            {
                Write-Output ("Error stopping virtual machine $VM_LIST.Name[$i]")
                Write-Output ($startStatus.Error)
            }
        }
        else
        {
            Write-Output ("Virtual machine $VM_LIST.Name[$i] is already in 'Running' state.")
        }

}
######################################################

###Stop VMs
$connectionName = "AzureRunAsConnection"

# Get the connection "AzureRunAsConnection "
$servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

"Logging in to Azure..."
Add-AzureRmAccount `
    -ServicePrincipal `
    -TenantId $servicePrincipalConnection.TenantId `
    -ApplicationId $servicePrincipalConnection.ApplicationId `
    -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 

#Getting the list of Resource groups with "Prprod" Prefix
$_preprodRG = Get-AzureRmResourceGroup | Where ResourceGroupName -like mc_tbs-rg-si-nld-preprod-*-hlf_tbs-si-nld-preprod-hlf-*-aks-01_southindia            

echo $_preprodRG
#devRG represents here all resources under Preprod
$devRG = @()
$devRG += $_preprodRG 

$dev_count=$devRG.count

echo $dev_count
#Initialzing Variables
$VM_LIST=@()
$VM_LIST_ALL = {}

#Fetch the List of VM in above mentioned RG
for($i=0;$i-le $dev_count-1;$i++)
{ 

$VM_LIST_ALL= Get-AzureRmVM -ResourceGroupName $devRG[$i].ResourceGroupName
if( $VM_LIST_ALL -eq $NULL)
    {
        continue;
    }
else
    {
        [array]$VM_LIST=[array]$VM_LIST+@(Get-AzureRmVM -ResourceGroupName $devRG[$i].ResourceGroupName)
    }
}
#Write-Output $VM_LIST

<#Write-Output $VM_LIST.Count#>
#$vmPowerstate=@()

#Stop Virtual Machines which are in Running State
for($i=0; $i-le ($VM_LIST.Count)-1;$i++)
{
    $VmStatus = Get-AzureRmVm -Name $VM_LIST.Name[$i] -ResourceGroupName $VM_LIST.ResourceGroupName[$i] -Status
    #[array]$vmPowerstate =[array]$vmPowerstate +@($vmStatus.PowerState)
    $vmPowerState = $VmStatus.Statuses.DisplayStatus[1]
    Write-Output $vmPowerstate

	if($vmPowerState -eq "VM Running")
        {
            Write-Output ("Stopping virtual machine"+ $VM_LIST.Name[$i])
            $stopStatus = Stop-AzureRmVm -Name $VM_LIST.Name[$i] -ResourceGroupName $VM_LIST.ResourceGroupName[$i] -Force
            if($stopStatus.Status -eq "Succeeded" -or $stopStatus.IsSuccessStatusCode -eq "True")
            {
                Write-Output ("Successfully stopped virtual machine"+ $VM_LIST.Name[$i])
            }
            else
            {
                Write-Output ("Error stopping virtual machine $VM_LIST.Name[$i]")
                Write-Output ($stopStatus.Error)
            }
        }
        else
        {
            Write-Output ("Virtual machine $VM_LIST.Name[$i] is already in 'Stopped' state.")
        }
}
################################################################
######Start VMSS
$connectionName = "AzureRunAsConnection"

# Get the connection "AzureRunAsConnection "
$servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

"Logging in to Azure..."
Add-AzureRmAccount `
    -ServicePrincipal `
    -TenantId $servicePrincipalConnection.TenantId `
    -ApplicationId $servicePrincipalConnection.ApplicationId `
    -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 

#Getting the list of Resource groups with "preprod" Prefix
$_preprodRG = Get-AzureRmResourceGroup | Where ResourceGroupName -like MC_TBS-RG-*-NLD-PreProd-Tanla*
$_preprodRG1 = Get-AzureRmResourceGroup | Where ResourceGroupName -like MC_TBS-RG-Entrp_TBS-NLD-PreProd-Entrp*
$_preprodRG2 = Get-AzureRmResourceGroup | Where ResourceGroupName -like MC_TBS-RG-TEL_TBS-NLD-PreProd-Tel*

#devRG represents here all resource groups under preprod
$devRG = @()
$devRG += $_preprodRG 
$devRG += $_preprodRG1
$devRG += $_preprodRG2
echo $devRG
$preprod_count = $devRG.count
echo $preprod_count

#Initilaizing variables
$VM_LIST=@()
$VM_LIST_ALL = {}

#Fetch the List of VM in above mentioned RG
for($i=0;$i-le $preprod_count-1;$i++)
{ 

$VM_LIST_ALL= Get-AzureRmVmss -ResourceGroupName $devRG[$i].ResourceGroupName
if( $VM_LIST_ALL -eq $NULL)
    {
        continue; 
    }
else
    {
        [array]$VM_LIST=[array]$VM_LIST+@(Get-AzureRmVmss -ResourceGroupName $devRG[$i].ResourceGroupName)
    }
}
<#Write-Output $VM_LIST
Write-Output $VM_LIST.Count
Write-Output $VM_LIST.Count-1


$vmPowerstate=@()
#>
#Starting Virtual Machines which are in Started State
for($i=0; $i-le ($VM_LIST.Count)-1;$i++)
{
    $VmStatus = Get-AzureRmVmSS -Name $VM_LIST.Name[$i] -ResourceGroupName $VM_LIST.ResourceGroupName[$i]
    $vmPowerState = $VmStatus.ProvisioningState

	if($vmPowerState -eq "Succeeded")
        {
            Write-Output ("Starting virtual machine"+ $VM_LIST.Name[$i])
            $startStatus = Start-AzureRmVmSS -Name $VM_LIST.Name[$i] -ResourceGroupName $VM_LIST.ResourceGroupName[$i] 
            if($startStatus.Status -eq "Succeeded" -or $startStatus.IsSuccessStatusCode -eq "True")
            {
                Write-Output ("Successfully started virtual machine"+ $VM_LIST.Name[$i])
            }
            else
            {
                Write-Output ("Error Starting virtual machine $VM_LIST.Name[$i]")
                Write-Output ($startStatus.Error)
            }
        }
        else
        {
            Write-Output ("Virtual machine $VM_LIST.Name[$i] is already in 'started' state.")
        }
}
#######################################################
##Stop VMSS
$connectionName = "AzureRunAsConnection"

# Get the connection "AzureRunAsConnection "
$servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

"Logging in to Azure..."
Add-AzureRmAccount `
    -ServicePrincipal `
    -TenantId $servicePrincipalConnection.TenantId `
    -ApplicationId $servicePrincipalConnection.ApplicationId `
    -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 

#Getting the list of Resource groups with "Preprod" Prefix
$_preprodRG = Get-AzureRmResourceGroup | Where ResourceGroupName -like MC_TBS-RG-*-NLD-PreProd-Tanla*
$_preprodRG1 = Get-AzureRmResourceGroup | Where ResourceGroupName -like MC_TBS-RG-Entrp_TBS-NLD-PreProd-Entrp*
$_preprodRG2 = Get-AzureRmResourceGroup | Where ResourceGroupName -like MC_TBS-RG-TEL_TBS-NLD-PreProd-Tel*

#devRG represents here all resources under Preprod
$devRG = @()
$devRG += $_preprodRG 
$devRG += $_preprodRG1
$devRG += $_preprodRG2
echo $devRG
$preprod_count = $devRG.count
echo $preprod_count

#Initilaizing variables
$VM_LIST=@()
$VM_LIST_ALL = {}

#Fetch the List of VM in above mentioned RG
for($i=0;$i-le $preprod_count-1;$i++)
{ 

$VM_LIST_ALL= Get-AzureRmVMSS -ResourceGroupName $devRG[$i].ResourceGroupName
if( $VM_LIST_ALL -eq $NULL)
    {
        continue; 
    }
else
    {
        [array]$VM_LIST=[array]$VM_LIST+@(Get-AzureRmVmSS -ResourceGroupName $devRG[$i].ResourceGroupName)
    }
}
<#Write-Output $VM_LIST
Write-Output $VM_LIST.Count
Write-Output $VM_LIST.Count-1


$vmPowerstate=@()
#>
#Stopping Virtual Machines which are in Running State
for($i=0; $i-le ($VM_LIST.Count)-1;$i++)
{
    $VmStatus = Get-AzureRmVMSS -Name $VM_LIST.Name[$i] -ResourceGroupName $VM_LIST.ResourceGroupName[$i]
    $vmPowerState = $VmStatus.ProvisioningState

	if($vmPowerState -eq "Succeeded")
        {
            Write-Output ("Stopping virtual machine"+ $VM_LIST.Name[$i])
            $stopStatus = Stop-AzureRmVmSS -Name $VM_LIST.Name[$i] -ResourceGroupName $VM_LIST.ResourceGroupName[$i] -Force
            if($stopStatus.Status -eq "Succeeded" -or $stopStatus.IsSuccessStatusCode -eq "True")
            {
                Write-Output ("Successfully stopped virtual machine"+ $VM_LIST.Name[$i])
            }
            else
            {
                Write-Output ("Error Stopping virtual machine $VM_LIST.Name[$i]")
                Write-Output ($stopStatus.Error)
            }
        }
        else
        {
            Write-Output ("Virtual machine $VM_LIST.Name[$i] is already in 'stopped' state.")
        }
}
