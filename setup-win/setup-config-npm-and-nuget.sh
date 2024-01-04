#!/bin/bash

nuget_source_github="https://nuget.pkg.github.com/Siteimprove/index.json"
npmrc_file="$USERPROFILE\.npmrc"

dotnet nuget list source | grep -q $nuget_source_github
found_nuget_source=$?

if [[ $found_nuget_source == 1 || ! -f "$npmrc_file" ]]; then
	echo
	echo "--- Configuring NPM and/or NuGet ---"
	echo
	echo "===> Create a GitHub PAT and copy it into the clipboard."
	echo "===> 1. Go to https://github.com/settings/tokens"
	echo "===> 2. Click 'Generate new token' and pick 'Generate new token (classic)' and authenticate to GitHub if needed"
	echo "===> 3. Name the token - e.g. 'GitHub Packages Read on Windows dev machine'"
	echo "===> 4. Select 'No expiration' and check the 'read:packages' permission"
	echo "===> 5. Click the 'Generate token' button"
	echo "===> 6. The token appears in the UI - now click the 'copy' button to copy it to the clipboard"
	echo "===> 7. For the new PAT, click the 'Configure SSO' dropdown and click 'Authorize' for the Siteimprove org"
	echo "===> Click 'enter' when done"
	read
	pat=$(< /dev/clipboard)

	if [ ! -f "$npmrc_file" ]; then
		echo "Configuring NPM"
		echo "@siteimprove:registry=https://npm.pkg.github.com/" >> "$npmrc_file"
		echo "//npm.pkg.github.com/:_authToken=$pat" >> "$npmrc_file"
	fi

	if [[ $found_nuget_source == 1 ]]; then
		echo "Configuring NuGet source for GitHub"
		dotnet nuget add source --username USERNAME --password $pat --store-password-in-clear-text --name "Siteimprove GitHub" $nuget_source_github
	fi 
fi

# TODO: Should we put the PAT in an env. var separate to this and then just generate it here without prompt? Maybe we could do the same with BC...

echo "Making sure LTS version of node and npm is installed"
volta install node

echo "Installing yarn as a global tool"
volta install yarn
