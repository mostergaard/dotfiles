#!/bin/sh

source ./brew.sh

system_type=$(uname -s)
if [[ "$system_type" = "Darwin" ]]; then
  setup_brew
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Detect it Dotnet core is installed and if not, output a link to install from