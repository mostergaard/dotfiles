#!/bin/sh

function setup_brew {
  # Check if homebrew is already installed
  brew_bin=$(which brew) 2>&1 > /dev/null
  if [[ $? != 0 ]]; then
    Echo "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ $? != 0 ]]; then
      echo "Failed to install Homebrew"
      exit 2
    fi
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