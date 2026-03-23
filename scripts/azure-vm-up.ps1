param(
    [string]$ResourceGroupName = "donationplatform-rg",
    [string]$Location = "swedencentral",
    [string]$VmName = "donationplatform-vm",
    [string]$AdminUsername = "azureuser",
    [string]$SshPublicKeyPath = "$HOME/.ssh/id_rsa.pub",
    [string]$VmSize = "Standard_B1s"
)

$ErrorActionPreference = "Stop"

$vnetName = "$VmName-vnet"
$subnetName = "$VmName-subnet"
$nsgName = "$VmName-nsg"
$publicIpName = "$VmName-pip"
$nicName = "$VmName-nic"

Write-Host "[1/7] Tjekker Azure login..."
$accountName = az account show --query "name" -o tsv
$subscriptionId = az account show --query "id" -o tsv
Write-Host "Aktiv subscription: $accountName ($subscriptionId)"

Write-Host "[2/7] Opretter resource group hvis den mangler..."
az group create --name $ResourceGroupName --location $Location 1>$null

Write-Host "[3/7] Opretter netvaerk hvis det mangler..."
az network vnet create `
  --resource-group $ResourceGroupName `
  --name $vnetName `
  --address-prefixes 10.0.0.0/16 `
  --subnet-name $subnetName `
  --subnet-prefixes 10.0.1.0/24 1>$null

Write-Host "[4/7] Opretter NSG og regler hvis de mangler..."
az network nsg create --resource-group $ResourceGroupName --name $nsgName 1>$null
az network nsg rule create --resource-group $ResourceGroupName --nsg-name $nsgName --name AllowSSH --priority 1000 --access Allow --protocol Tcp --direction Inbound --source-address-prefixes '*' --source-port-ranges '*' --destination-address-prefixes '*' --destination-port-ranges 22 1>$null
az network nsg rule create --resource-group $ResourceGroupName --nsg-name $nsgName --name AllowApp4567 --priority 1010 --access Allow --protocol Tcp --direction Inbound --source-address-prefixes '*' --source-port-ranges '*' --destination-address-prefixes '*' --destination-port-ranges 4567 1>$null

Write-Host "[5/7] Opretter statisk public IP hvis den mangler..."
az network public-ip create `
  --resource-group $ResourceGroupName `
  --name $publicIpName `
  --sku Standard `
  --allocation-method Static 1>$null

Write-Host "[6/7] Opretter NIC hvis den mangler..."
az network nic create `
  --resource-group $ResourceGroupName `
  --name $nicName `
  --vnet-name $vnetName `
  --subnet $subnetName `
  --network-security-group $nsgName `
  --public-ip-address $publicIpName 1>$null

$vmExists = az vm list --resource-group $ResourceGroupName --query "[?name=='$VmName'].name | [0]" -o tsv

if (-not $vmExists) {
    Write-Host "[7/7] Opretter VM..."
    if (Test-Path $SshPublicKeyPath) {
        az vm create `
          --resource-group $ResourceGroupName `
          --name $VmName `
          --image Ubuntu2204 `
          --size $VmSize `
          --admin-username $AdminUsername `
          --authentication-type ssh `
          --ssh-key-values $SshPublicKeyPath `
          --nics $nicName 1>$null
    }
    else {
        Write-Host "SSH public key blev ikke fundet på '$SshPublicKeyPath'. Opretter nøgler automatisk..."
        az vm create `
          --resource-group $ResourceGroupName `
          --name $VmName `
          --image Ubuntu2204 `
          --size $VmSize `
          --admin-username $AdminUsername `
          --authentication-type ssh `
          --generate-ssh-keys `
          --nics $nicName 1>$null
    }
}
else {
    Write-Host "[7/7] VM findes allerede, starter den..."
    az vm start --resource-group $ResourceGroupName --name $VmName 1>$null
}

$ip = az network public-ip show --resource-group $ResourceGroupName --name $publicIpName --query "ipAddress" -o tsv
$vmId = az vm list --resource-group $ResourceGroupName --query "[?name=='$VmName'].id | [0]" -o tsv
if (-not $vmId) {
  Write-Host "Fejl: VM blev ikke fundet efter up-script i resource group '$ResourceGroupName'."
  exit 1
}

Write-Host "Ferdig. VM oprettet/startet."
Write-Host "VM id: $vmId"
Write-Host "VM navn: $VmName"
Write-Host "Resource group: $ResourceGroupName"
Write-Host "Public IP (fast): $ip"
