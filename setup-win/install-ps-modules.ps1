function Install-If-Not-Found([string] $ModuleName)
{
	if (-Not (Get-Module -ListAvailable -Name $ModuleName)) {
		Install-Module -Name $ModuleName -Force  
	}
}

Install-If-Not-Found "posh-git"
Install-If-Not-Found "ZLocation"
Install-If-Not-Found "PSReadLine"
Install-If-Not-Found "AWSPowerShell"
Install-If-Not-Found "PSKubectlCompletion"
