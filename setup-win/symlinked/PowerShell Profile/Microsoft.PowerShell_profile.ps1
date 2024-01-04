# Ideas from https://thirty25.com/posts/2021/12/optimizing-your-powershell-load-times

function Run-Step([string] $Description, [ScriptBlock]$script)
{
	Write-Host  -NoNewline "Loading" $Description.PadRight(40)
	& $script
	Write-Host "`u{2705}" # checkmark emoji
}

Write-Host "Loading PowerShell $($PSVersionTable.PSVersion)..." -ForegroundColor 3
Write-Host

Run-Step "Posh-Git" {
	Import-Module posh-git
	$env:POSH_GIT_ENABLED = $true
}

Run-Step "on-my-posh" {
	oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\jandedobbeleer.omp.json" | Invoke-Expression	
}

Run-Step "ZLocation" {
	Import-Module ZLocation
}

Run-Step "PSReadline" {
  Import-Module PSReadLine
}

# This is SLOW! So skipped for now...
# Run-Step "AWS" {
	# Import-Module AWSPowerShell
# }

Run-Step "Kubectl autocompletion" {
	Import-Module -Name PSKubectlCompletion
	Register-KubectlCompletion
}
