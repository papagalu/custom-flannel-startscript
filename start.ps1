Param(
    [parameter(Mandatory = $true)] $ClusterCIDR,
    [parameter(Mandatory = $true)] $ManagementIP,
    [parameter(Mandatory = $true)] $KubeDnsServiceIP,
    [parameter(Mandatory = $true)] $ServiceCIDR,
    [parameter(Mandatory = $false)] $InterfaceName="Ethernet",
    [parameter(Mandatory = $false)] $LogDir = "C:\k",
    [ValidateSet("process", "hyperv")] $IsolationType = "process"
)

$ErrorActionPreference = "Stop";

# Prepare POD infra Images
start powershell $BaseDir\InstallImages.ps1

# Prepare Network & Start Infra services
$NetworkMode = "L2Bridge"
$NetworkName = "cbr0"
CleanupOldNetwork $NetworkName
powershell $BaseDir\start-kubelet.ps1 -RegisterOnly
ipmo C:\k\hns.psm1

# Create a L2Bridge to trigger a vSwitch creation. Do this only once as it causes network blip
if(!(Get-HnsNetwork | ? Name -EQ "External"))
{
    New-HNSNetwork -Type $NetworkMode -AddressPrefix "192.168.255.0/30" -Gateway "192.168.255.1" -Name "External" -Verbose
}
# Start Flanneld
Start-Sleep 5
StartFlanneld -ipaddress $ManagementIP -NetworkName $NetworkName

# Start kubelet
Start powershell -ArgumentList "-File $BaseDir\start-kubelet.ps1 -clusterCIDR $ClusterCIDR -KubeDnsServiceIP $KubeDnsServiceIP -serviceCIDR $ServiceCIDR -InterfaceName $InterfaceName -LogDir $LogDir -IsolationType $IsolationType -NetworkName $NetworkName"
Start-Sleep 10

# Start kube-proxy
start powershell -ArgumentList " -File $BaseDir\start-kubeproxy.ps1 -NetworkName $NetworkName -LogDir $LogDir"
