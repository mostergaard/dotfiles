#!/bin/sh

source ./brew.sh

function ensure_admin {
  # Unlike `id`, dseditgroup asks the directory, so a grant made while this script runs is picked up
  until dseditgroup -o checkmember -m "$USER" admin > /dev/null 2>&1; do
    echo "===> The next step needs admin privileges. Request them through the Self Service+ app and press <enter> to continue."
    read
  done
}

function setup_oh_my_zsh {
  if [[ -z "${ZSH}" ]]; then
    echo "Installing Oh My Zsh"
    # RUNZSH=no stops the installer from exec'ing into zsh, which would end this script early.
    # KEEP_ZSHRC=yes stops it from replacing ~/.zshrc, which is linked to the repo by config_dotfiles.
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
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
  if [[ ! -d /Applications/Xcode.app ]]; then
    ensure_admin
    echo "Installing Xcode from App store"
    sudo mas install 497799835
  fi

  # Use Xcode's own xcodebuild, as xcode-select may still point at the Command Line Tools
  xcodebuild=/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild
  if ! $xcodebuild -license check > /dev/null 2>&1; then
    ensure_admin
    echo "Accepting the Xcode license"
    sudo $xcodebuild -license accept
  fi
}

function config_git {
  echo "Setting up Git username and profile"
  git config --global user.name "Morten Østergaard"
  git config --global user.email moni@siteimprove.com
}

function config_jdk {
  jdk_target=/opt/homebrew/opt/openjdk/libexec/openjdk.jdk
  jdk_link=/Library/Java/JavaVirtualMachines/openjdk.jdk
  if [[ "$(readlink "$jdk_link")" != "$jdk_target" ]]; then
    ensure_admin
    echo "Configuring JDK"
    sudo ln -sfn "$jdk_target" "$jdk_link"
  fi
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

function config_file_associations {
  echo "Setting default apps for file types"
  duti ./file-associations.duti
}

function config_macos {
  echo "Configuring macOS settings (trackpad and keyboard changes apply after logging out and in)"
  # Built-in and Bluetooth trackpads: tap to click and three-finger drag.
  # Like System Settings does, three-finger drag moves the swipes between Spaces and to Mission Control to four fingers.
  for trackpad in com.apple.AppleMultitouchTrackpad com.apple.driver.AppleBluetoothMultitouch.trackpad; do
    defaults write $trackpad Clicking -bool true
    defaults write $trackpad TrackpadThreeFingerDrag -bool true
    defaults write $trackpad TrackpadThreeFingerHorizSwipeGesture -int 0
    defaults write $trackpad TrackpadThreeFingerVertSwipeGesture -int 0
    defaults write $trackpad TrackpadFourFingerHorizSwipeGesture -int 2
    defaults write $trackpad TrackpadFourFingerVertSwipeGesture -int 2
  done
  defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  defaults write NSGlobalDomain com.apple.mouse.scaling -float 0.875

  defaults write NSGlobalDomain AppleInterfaceStyle Dark

  defaults write com.apple.dock tilesize -int 41
  defaults write com.apple.dock magnification -bool true
  defaults write com.apple.dock largesize -int 50
  defaults write com.apple.dock show-recents -bool false
  # No hot corners (1 = no action), which also removes Quick Note from the bottom-right corner
  for corner in tl tr bl br; do
    defaults write com.apple.dock wvous-$corner-corner -int 1
    defaults write com.apple.dock wvous-$corner-modifier -int 0
  done
  killall Dock

  # Column view, path bar, and new windows showing the Computer
  defaults write com.apple.finder FXPreferredViewStyle clmv
  defaults write com.apple.finder ShowPathbar -bool true
  defaults write com.apple.finder NewWindowTarget PfCm
  killall Finder

  defaults write com.apple.WindowManager EnableTiledWindowMargins -bool false

  # The fastest repeat and shortest delay offered in System Settings
  defaults write NSGlobalDomain KeyRepeat -int 2
  defaults write NSGlobalDomain InitialKeyRepeat -int 15
  # F1-F12 act as function keys without holding Fn
  defaults write NSGlobalDomain com.apple.keyboard.fnState -bool true

  # Disable "Show Desktop" (hotkey 36) so F11 reaches the debugger as "step into"
  defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 36 \
    "<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>103</integer><integer>8388608</integer></array><key>type</key><string>standard</string></dict></dict>"
  /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
}

function config_dotfiles {
  echo "Linking dotfiles into $HOME"
  # Link files rather than folders, as apps often keep machine state next to their config (e.g. ~/.claude)
  find "$PWD/home" -type f ! -name .DS_Store | while read -r source; do
    target="$HOME/${source#$PWD/home/}"
    mkdir -p "$(dirname "$target")"
    if [[ "$(readlink "$target")" == "$source" ]]; then
      continue
    fi
    # Also catches a link that a tool has replaced with a regular file
    if [[ -e "$target" || -L "$target" ]]; then
      backup="$target.backup-$(date +%Y%m%d%H%M%S)"
      echo "Moving existing $target to $backup"
      mv "$target" "$backup"
    fi
    ln -s "$source" "$target"
  done
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
  config_file_associations
  config_macos
  config_dotfiles
fi
