#!/bin/bash

echo Setting PowerShell execution policy
pwsh -NoProfile -NoLogo -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned" 

echo Installing PowerShell modules
pwsh -NoProfile -NoLogo "./install-ps-modules.ps1"

ps_folder="$USERPROFILE\Documents\PowerShell"
ps_profile_file="$ps_folder\Microsoft.PowerShell_profile.ps1"
source="C:\code\dotfiles\setup-win\symlinked\PowerShell Profile\Microsoft.PowerShell_profile.ps1"

if [ ! -f "$ps_profile_file" ]; then
	if [ ! -d "$ps_folder" ]; then
		echo "Creating PowerShell profiles folder"
		mkdir -p "$ps_folder";
	fi
	
	echo "Creating PowerShell profile linked file"
	ln -T "$source" "$ps_profile_file"
fi

# TODO: Install fonts, and configure the Oh My Gosh profile correctly. 
