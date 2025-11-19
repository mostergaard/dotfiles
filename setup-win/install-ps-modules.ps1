function Install-If-Not-Found([string] $ModuleName)
{
	if (-Not (Get-Module -ListAvailable -Name $ModuleName)) {
		Write-Host "Module $ModuleName not found. Installing..."
		Install-Module -Name $ModuleName -Force  
	} else {
		Write-Host "Module $ModuleName is already installed."	
	}
}

Install-If-Not-Found "posh-git"
Install-If-Not-Found "ZLocation"
Install-If-Not-Found "PSReadLine"
Install-If-Not-Found "AWSPowerShell"
Install-If-Not-Found "PSKubectlCompletion"
