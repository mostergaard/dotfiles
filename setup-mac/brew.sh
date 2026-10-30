#!/bin/sh

function casks_to_skip {
  # Apps already in /Applications that Homebrew can't manage: installed outside Homebrew, or taken over by AppBar
  # (IT's updater), which updates them as root. brew bundle fails on these, and AppBar keeps them updated anyway.
  local installed
  installed=$(brew list --cask)
  brew info --cask --json=v2 $(brew bundle list --cask) \
    | jq -r '.casks[] | .token as $t | .artifacts[] | .app? // empty | .[] | strings | "\($t)\t\(.)"' \
    | while IFS="	" read -r token app; do
        target="/Applications/$app"
        [[ -e "$target" ]] || continue
        if ! echo "$installed" | grep -qxF "$token" || [[ "$(stat -f %Su "$target")" != "$USER" ]]; then
          echo "$token"
        fi
      done | sort -u
}

function casks_needing_admin {
  # Casks not installed yet that run a .pkg or copy an app into /Applications - both need admin for a standard user.
  # Apps already in /Applications (installed outside Homebrew) are skipped, as brew bundle fails on those anyway.
  local installed missing
  installed=$(brew list --cask)
  missing=$(brew bundle list --cask | grep -vxF "$installed")
  [[ -z "$missing" ]] && return
  brew info --cask --json=v2 $missing \
    | jq -r '.casks[] | .token as $t | .artifacts[] | (.pkg? // empty | "pkg\t\($t)\t"), (.app? // empty | .[] | strings | "app\t\($t)\t\(.)")' \
    | while IFS="	" read -r kind token app; do
        if [[ "$kind" == "pkg" || ! -e "/Applications/$app" ]]; then
          echo "$token"
        fi
      done | sort -u
}

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

  skip_casks=$(echo $(casks_to_skip))
  if [[ -n "$skip_casks" ]]; then
    echo "Skipping apps managed outside Homebrew: $skip_casks"
  fi

  admin_casks=$(casks_needing_admin)
  if [[ -n "$admin_casks" ]]; then
    echo "These apps need admin privileges to install: $(echo $admin_casks)"
    ensure_admin
  fi

  echo "Running Brew bundle"
  HOMEBREW_BUNDLE_CASK_SKIP="$skip_casks" brew bundle
}