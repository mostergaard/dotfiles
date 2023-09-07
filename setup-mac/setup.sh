#!/bin/sh

source ./brew.sh

system_type=$(uname -s)
if [[ "$system_type" = "Darwin" ]]; then
  setup_brew
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi