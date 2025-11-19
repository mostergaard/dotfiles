#!/bin/bash

echo Setting PowerShell execution policy
pwsh -NoProfile -NoLogo -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned" 

echo Installing PowerShell modules
pwsh -NoProfile -NoLogo "./install-ps-modules.ps1"

ps_folder="${PROGRAMFILES}\PowerShell\7"
ps_profile_file="$ps_folder\Microsoft.PowerShell_profile.ps1"
ps_profile_source="C:\code\dotfiles\setup-win\symlinked\PowerShell Profile\Microsoft.PowerShell_profile.ps1"
if [ ! -f "$ps_profile_file" ]; then
	if [ ! -d "$ps_folder" ]; then
		echo "Creating PowerShell profiles folder"
		mkdir -p "$ps_folder";
	fi
	
	echo "Creating PowerShell profile linked file"
	ln -T "$ps_profile_source" "$ps_profile_file"
fi

if [ ! -f "C:\Windows\Fonts\FiraCodeNerdFont-Regular.ttf" ]; then
	echo Installing FiraCode font
	oh-my-posh font install FiraCode
fi

if [ ! -f "C:\Windows\Fonts\MesloLGLNerdFont-Regular.ttf" ]; then
	echo Installing Meslo LGM NerdFont
	oh-my-posh font install Meslo LGM NF
fi

wt_folder="${LOCALAPPDATA}\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
wt_settings_file="$wt_folder\settings.json"
wt_state_file="$wt_folder\state.json"
wt_settings_source="C:\code\dotfiles\setup-win\symlinked\Windows Terminal\settings.json"
echo "Creating Windows Terminal settings linked file from ${wt_settings_source} to ${wt_settings_file}"
ln -fT "$wt_settings_source" "$wt_settings_file"
rm -f "$wt_folder\state.json"
rm -f "$wt_folder\elevated-state.json"

# I think this is causing issues, so commenting out for now!
# scripts_folder="C:\code\dotfiles\setup-win\scripts"
# if [[ ! $PATH == *$scripts_folder* ]]; then
# 	echo Adding $scripts_folder to path
# 	pwsh -NoProfile -NoLogo -Command "[Environment]::SetEnvironmentVariable(\"Path\", \$env:Path + \";$scripts_folder\", \"User\")" 
# fi

# echo "Testing if path starts with ."
# echo $PATH
# if [[ ! $PATH == .\;* ]]; then
# 	echo Adding "." to path so that local Powershell scripts can be run without adding ./ in front
# 	pwsh -NoProfile -NoLogo -Command "[Environment]::SetEnvironmentVariable(\"Path\", \".;\" + \$env:Path, \"User\")" 
# fi

# TODO: Setup symlinks for PowerToys Keyboard Manager stored in %LOCALAPPDATA%\Microsoft\PowerToys\Keyboard Manager (settings.json and default.json)