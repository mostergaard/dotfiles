#!/bin/sh

function setup_brew {
  # Check if homebrew is already installed
  brew_bin=$(which brew) 2>&1 > /dev/null
  if [[ $? != 0 ]]; then
    echo "Installing Homebrew"
    # The install.sh script needs sudo, which a standard (non-admin) user doesn't have.
    # The official .pkg can be elevated by Privilege Management, and leaves /opt/homebrew owned by us.
    pkg_url=$(curl -fsSL https://api.github.com/repos/Homebrew/brew/releases/latest | grep -o 'https://[^"]*\.pkg' | head -n 1)
    pkg_file="${TMPDIR:-/tmp}/Homebrew.pkg"
    curl -fsSL "$pkg_url" -o "$pkg_file"
    echo "===> Complete the Homebrew installer that opened (approve the elevation prompt if asked). Waiting..."
    open -W "$pkg_file"
    rm -f "$pkg_file"
    if [[ ! -x /opt/homebrew/bin/brew ]]; then
      echo "Failed to install Homebrew"
      exit 2
    fi
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    echo "Updating Homebrew"
    brew update
  fi
  
  echo "Trusting Brew taps"
  brew trust microsoft/git
  brew trust hashicorp/tap
  brew trust chainguard-dev/tap
  brew trust --formula huseyinbabal/tap/taws
  brew trust --formula anomalyco/tap/opencode

  echo "Running Brew bundle"
  brew bundle 
}