# The following lines were added by Docker Desktop to add commands to your PATH.
export PATH="$PATH:$HOME/.docker/bin"
# End of Docker Desktop section.

eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="${HOMEBREW_PREFIX}/opt/openssl/bin:$PATH"
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
