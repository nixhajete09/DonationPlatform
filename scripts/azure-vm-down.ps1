param(
    [string]$ResourceGroupName = "donationplatform-rg",
    [string]$VmName = "donationplatform-vm",
    [string]$PublicIpName = ""
)

$ErrorActionPreference = "Stop"

Write-Host "Tjekker Azure login..."
az account show 1>$null

if ([string]::IsNullOrWhiteSpace($PublicIpName)) {
    $PublicIpName = "$VmName-pip"
}

$vmExists = az vm list --resource-group $ResourceGroupName --query "[?name=='$VmName'].name | [0]" -o tsv
if (-not $vmExists) {
    Write-Host "VM blev ikke fundet i resource group '$ResourceGroupName'. Proever at finde VM i hele subscription..."
    $vmMatches = az vm list --query "[?name=='$VmName'].resourceGroup" -o tsv

    if (-not $vmMatches) {
        Write-Host "VM '$VmName' blev ikke fundet i subscription."
        exit 1
    }

    $uniqueGroups = $vmMatches -split "`n" | Where-Object { $_ -and $_.Trim() -ne "" } | Sort-Object -Unique
    if ($uniqueGroups.Count -gt 1) {
        Write-Host "VM-navnet findes i flere resource groups. Angiv -ResourceGroupName eksplicit."
        $uniqueGroups | ForEach-Object { Write-Host "- $_" }
        exit 1
    }

    $ResourceGroupName = $uniqueGroups[0]
    Write-Host "Bruger auto-detekteret resource group: $ResourceGroupName"
}

$allocationMethod = az network public-ip show --resource-group $ResourceGroupName --name $PublicIpName --query "publicIPAllocationMethod" -o tsv 2>$null
$oldIp = az network public-ip show --resource-group $ResourceGroupName --name $PublicIpName --query "ipAddress" -o tsv 2>$null

if (-not $oldIp -or $allocationMethod -ne "Static") {
    Write-Host "Stopper: Public IP mangler eller er ikke statisk. Sletter ikke VM."
    exit 1
}

$nicId = az vm show --resource-group $ResourceGroupName --name $VmName --query "networkProfile.networkInterfaces[0].id" -o tsv
$nicName = if ($nicId) { ($nicId -split '/')[-1] } else { "$VmName-nic" }
$osDiskName = az vm show --resource-group $ResourceGroupName --name $VmName --query "storageProfile.osDisk.name" -o tsv

Write-Host "Sletter VM..."
az vm delete --resource-group $ResourceGroupName --name $VmName --yes
az vm wait --resource-group $ResourceGroupName --name $VmName --deleted

$newIp = az network public-ip show --resource-group $ResourceGroupName --name $PublicIpName --query "ipAddress" -o tsv 2>$null
if (-not $newIp -or $newIp -ne $oldIp) {
    Write-Host "Stopper cleanup: IP-adresse kunne ikke bekrftes som uendret efter VM-sletning."
    exit 1
}

Write-Host "IP er uendret ($newIp). Fortsaetter med cleanup af VM-relaterede resources..."

if ($nicName) {
    $nicExists = az network nic show --resource-group $ResourceGroupName --name $nicName --query "name" -o tsv 2>$null
    if ($nicExists) {
        az network nic delete --resource-group $ResourceGroupName --name $nicName
    }
}

if ($osDiskName) {
    $diskExists = az disk show --resource-group $ResourceGroupName --name $osDiskName --query "name" -o tsv 2>$null
    if ($diskExists) {
        az disk delete --resource-group $ResourceGroupName --name $osDiskName --yes
    }
}

Write-Host "Ferdig. VM er slettet, og public IP er bevaret: $newIp"
