#!/bin/bash

#TODO: Setup some alias to run this script to e.g. update latest
#versions of software etc.

cd $(dirname "$0")

./setup-winget.sh

echo "===> Some of the installs might add new PATH vars, in which case you will have to restart the terminal and run the setup again..."

./setup-config-git.sh
./setup-config-bc.sh
./setup-config-terminals.sh
./setup-config-npm-and-nuget.sh
