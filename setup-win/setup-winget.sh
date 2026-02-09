#!/bin/bash

echo Installing DotNet SDK version 8
winget install Microsoft.DotNet.SDK.8

# This doesn't seem to work anymore. Use the Company Portal to install
# echo Installing Visual Studio 2022 Professional
# winget install --id Microsoft.VisualStudio.2022.Professional --override "--quiet --passive --config c:\code\dotfiles\setup-win\vs2022prof.vsconfig"

echo Installing Visual Studio Code
winget install --id Microsoft.VisualStudioCode

echo Installing Volta
winget install --id Volta.Volta

echo Installing PowerShell Core
winget install --id Microsoft.PowerShell

echo Installing Notepad++
winget install --id Notepad++.Notepad++

echo Installing Beyond Compare
winget install --id ScooterSoftware.BeyondCompare.5

# This doesn't seem to be allowed anymore. Install through the Company Portal instead, where I got it added
# echo Installing Oh My Posh
# winget install JanDeDobbeleer.OhMyPosh --source winget

echo Installing PowerToys
winget install Microsoft.PowerToys

echo Installing Docker Desktop
winget install Docker.DockerDesktop

echo Installing Redis Insight
winget install RedisInsight.RedisInsight

echo Installing Github CLI
winget install --id GitHub.cli

echo Installing AWS CLI
winget install --id Amazon.AWSCLI

echo Installing k9s
winget install --id=Derailed.k9s -e

echo Installing Skaffold
winget install --id Google.ContainerTools.Skaffold -e

echo Installing Kustomize
winget install --id=Kubernetes.kustomize -e

echo Installing Terraform
winget install --id=Hashicorp.Terraform -e

echo Installing chainctl
winget install --id=Chainguard.chainctl -e

echo Installing Cilium CLI
winget install --id=Cilium.CiliumCLI -e

echo Enabling Windows features for Containers and Hyper-V
powershell.exe -Command "Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V, Containers -All"

# We are using WSL2 for Docker, so we may not need Hyper-V enabled anyway...
# echo Enabling Hyper-V feature
# dism.exe /Online /Enable-Feature:Microsoft-Hyper-V /All

