$ErrorActionPreference = "Stop";

function SetupDirectories()
{
    md $BaseDir -ErrorAction Ignore
    md $LogDir -ErrorAction Ignore
    md c:\flannel -ErrorAction Ignore
    md $BaseDir\cni\config -ErrorAction Ignore
    md C:\etc\kube-flannel -ErrorAction Ignore
}

function CopyFiles(){
    cp $BaseDir\flanneld.exe c:\flannel\flanneld.exe
    cp $BaseDir\net-conf.json C:\etc\kube-flannel\net-conf.json
}

function DownloadFlannelBinaries()
{
    Write-Host "Downloading Flannel binaries"
    DownloadFile -Url  "https://raw.githubusercontent.com/Microsoft/SDN/master/Kubernetes/flannel/l2bridge/flanneld.exe" -Destination $BaseDir\flanneld.exe 
}

function DownloadCniBinaries()
{
    Write-Host "Downloading CNI binaries"
    DownloadFile -Url  "https://raw.githubusercontent.com/Microsoft/SDN/master/Kubernetes/flannel/l2bridge/cni/flannel.exe" -Destination $BaseDir\cni\flannel.exe
    DownloadFile -Url  "https://raw.githubusercontent.com/Microsoft/SDN/master/Kubernetes/flannel/l2bridge/cni/win-bridge.exe" -Destination $BaseDir\cni\win-bridge.exe
    DownloadFile -Url  "https://raw.githubusercontent.com/Microsoft/SDN/master/Kubernetes/flannel/l2bridge/cni/host-local.exe" -Destination $BaseDir\cni\host-local.exe
    DownloadFile -Url  "https://raw.githubusercontent.com/Microsoft/SDN/master/Kubernetes/flannel/l2bridge/net-conf.json" -Destination $BaseDir\net-conf.json
}

function DownloadWindowsKubernetesScripts()
{
    Write-Host "Downloading Windows Kubernetes scripts"
    DownloadFile -Url  "https://raw.githubusercontent.com/Microsoft/SDN/master/Kubernetes/windows/hns.psm1" -Destination $BaseDir\hns.psm1
    DownloadFile -Url  "https://raw.githubusercontent.com/Microsoft/SDN/master/Kubernetes/windows/InstallImages.ps1" -Destination $BaseDir\InstallImages.ps1
    DownloadFile -Url  "https://raw.githubusercontent.com/Microsoft/SDN/master/Kubernetes/windows/Dockerfile" -Destination $BaseDir\Dockerfile
    DownloadFile -Url  "https://raw.githubusercontent.com/Microsoft/SDN/master/Kubernetes/flannel/stop.ps1" -Destination $BaseDir\stop.ps1
    DownloadFile -Url  "https://raw.githubusercontent.com/Microsoft/SDN/master/Kubernetes/flannel/l2bridge/start-kubelet.ps1" -Destination $BaseDir\start-Kubelet.ps1 
    DownloadFile -Url  "https://raw.githubusercontent.com/Microsoft/SDN/master/Kubernetes/windows/start-kubeproxy.ps1" -Destination $BaseDir\start-Kubeproxy.ps1
}

function DownloadAllFiles()
{
    DownloadFlannelBinaries
    DownloadCniBinaries
}

$BaseDir = "c:\k"
SetupDirectories

$helper = "c:\k\helper.psm1"
if (!(Test-Path $helper))
{
     curl.exe https://raw.githubusercontent.com/papagalu/custom-flannel-startscript/master/helper.psm1 --output C:\k\helper.psm1
}
ipmo $helper

DownloadWindowsKubernetesScripts

DownloadAllFiles
CopyFiles
