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

  # Detect it Dotnet core is installed and if not, output a link to install from
  echo "Installing .NET Core"

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

system_type=$(uname -s)
if [[ "$system_type" = "Darwin" ]]; then
  setup_brew
  setup_oh_my_zsh
  config_k8s
  #setup_dotnet
fi
