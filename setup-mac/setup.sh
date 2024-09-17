#!/bin/sh

source ./brew.sh

function setup_oh_my_zsh {
  if [[ -z "${ZSH}" ]]; then
    echo "Installing Oh My Zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  else
    $ZSH/tools/upgrade.sh
  fi
}

function setup_dotnet {
  # TODO: Detect it Dotnet core is installed and if not, output a link to install from
  echo "Installing .NET Core"
}

function setup_rust {
  echo "Setting up Rust"
  rustup-init --no-modify-path -y 
}

function setup_xcode {
  # Install Xcode through the Mac App Store - using the "mas" CLI installed throw Brew. The xcode app has ID 497799835
  echo "Installing Xcode from App store"
  mas install 497799835

  echo "Accepting the Xcode license"
  sudo xcodebuild -license accept
}

function config_git {
  echo "Setting up Git username and profile"
  git config --global user.name "Morten Østergaard"
  git config --global user.email moni@siteimprove.com
}

function config_jdk {
  echo "Configuring JDK"
  sudo ln -sfn /opt/homebrew/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
}

function config_k8s {
  kubeconfig_folder="$HOME/.kube"
  kubeconfig_file="$kubeconfig_folder/config"
  if [ ! -f "$kubeconfig_file" ]; then
    echo "===> Go to https://login.stmprv.io/, authenticate, and choose "Full Kubeconfig". Copy the full config to clipboard and press <enter> to contiue."
    read
    kubeconfig="$(pbpaste)"
    if [ ! -d "$kubeceonfig_folder" ]; then
      mkdir -p "$kubeconfig_folder";
    fi	
    echo "$kubeconfig" >> "$kubeconfig_file"
  fi
}

function config_npm_and_nuget {
  nuget_source_github="https://nuget.pkg.github.com/Siteimprove/index.json"
  npmrc_file="$HOME/.npmrc"

  dotnet nuget list source | grep -q $nuget_source_github
  found_nuget_source=$?

  if [[ $found_nuget_source == 1 || ! -f "$npmrc_file" ]]; then
    echo
    echo "--- Configuring NPM and/or NuGet ---"
    echo
    echo "===> Create a GitHub PAT and copy it into the clipboard."
    echo "===> 1. Go to https://github.com/settings/tokens"
    echo "===> 2. Click 'Generate new token' and pick 'Generate new token (classic)' and authenticate to GitHub if needed"
    echo "===> 3. Name the token - e.g. 'GitHub Packages Read on Mac dev machine'"
    echo "===> 4. Select 'No expiration' and check the 'read:packages' permission"
    echo "===> 5. Click the 'Generate token' button"
    echo "===> 6. The token appears in the UI - now click the 'copy' button to copy it to the clipboard"
    echo "===> 7. For the new PAT, click the 'Configure SSO' dropdown and click 'Authorize' for the Siteimprove org"
    echo "===> Click 'enter' when done"
    read
    pat="$(pbpaste)"

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

  echo "Making sure LTS version of node and npm is installed"
  volta install node

  echo "Installing npm as a global tool"
  volta install npm

  echo "Installing yarn as a global tool"
  volta install yarn

  echo "Installing pnpm as a global tool"
  volta install pnpm
}

function config_bc {
  echo "Configuring Beyond Compare"
  bc4key_folder="$HOME/Library/Application Support/Beyond Compare"
  bc4key_file="$bc4key_folder/BC4Key.txt"
  if [ ! -f "$bc4key_file" ]; then
    echo "===> Copy Beyond Compare license key into clipboard and press <enter> to contiue. Hint, the whole key is in my password app!"
    read
    bc4key=$(pbpaste)
    if [ ! -d "$bc4key_folder" ]; then
      mkdir -p "$bc4key_folder";
    fi	
    echo "$bc4key" >> "$bc4key_file"
  fi
}

system_type=$(uname -s)
if [[ "$system_type" = "Darwin" ]]; then
  setup_brew
  setup_oh_my_zsh
  setup_dotnet
  setup_rust
  setup_xcode
  config_git
  config_jdk
  config_k8s
  config_npm_and_nuget
  config_bc
fi
