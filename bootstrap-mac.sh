#!/bin/bash

# Download this file directly from GitHub to a temporary place and execute it - see README.md.
# Don't pipe it into bash: the setup scripts read from the terminal.

set -e

# /usr/bin/git is only a stub until the Command Line Tools are installed. Homebrew needs them as well.
# The latest Git gets installed later through the Brewfile.
echo "-- Making sure the Xcode Command Line Tools are installed..."
echo
if ! xcode-select -p > /dev/null 2>&1; then
  xcode-select --install
  echo "===> Finish the Command Line Tools install in the dialog that opened. Waiting..."
  until xcode-select -p > /dev/null 2>&1; do
    sleep 5
  done
fi

echo
echo "-- Making sure ~/Code exists..."
echo
mkdir -p "$HOME/Code"
cd "$HOME/Code"

if [ ! -d dotfiles ]; then
  echo
  echo "-- Checking out the \"dotfiles\" repo from GitHub..."
  echo
  git clone https://github.com/mostergaard/dotfiles.git
  cd dotfiles
else
  echo
  echo "-- Updating the \"dotfiles\" repo..."
  echo
  cd dotfiles
  git pull
fi

echo
echo "-- Executing the setup script from \"dotfiles\"..."
echo
# setup.sh sources brew.sh and runs brew bundle relative to the working directory
(cd setup-mac && ./setup.sh)

echo
echo "-- Finished bootstrapping on Mac"
echo
