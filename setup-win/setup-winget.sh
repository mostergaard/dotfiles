#!/bin/bash

echo Installing DotNet SDK
winget install Microsoft.DotNet.SDK.7

echo Installing Visual Studio 2022 Professional
winget install --id Microsoft.VisualStudio.2022.Professional --override "--quiet --passive --config c:\code\dotfiles\setup-win\vs2022prof.vsconfig"

echo Installing Visual Studio Code
winget install --id Microsoft.VisualStudioCode

echo Installing Windows Terminal
winget install --id Microsoft.WindowsTerminal

echo Installing Volta
winget install --id Volta.Volta

ps_version=$( pwsh --version )
if [[ $ps_version == *"7.3.9"* ]]; then
	echo Uninstalling old PowerShell version because the install system is different
	winget uninstall --id Microsoft.PowerShell --version 7.3.9
fi

echo Installing PowerShell Core
winget install --id Microsoft.PowerShell

echo Installing Notepad++
winget install --id Notepad++.Notepad++

echo Installing Beyond Compare
winget install --id ScooterSoftware.BeyondCompare4

echo Installing Oh My Posh
winget install JanDeDobbeleer.OhMyPosh
