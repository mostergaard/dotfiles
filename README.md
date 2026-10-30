# Bootstrap on Windows

Open a new Windows terminal IN ADMIN, and copy-paste this command to execute it:
```
powershell -c "iwr -useb https://raw.githubusercontent.com/mostergaard/dotfiles/refs/heads/main/bootstrap-win.cmd -OutFile $env:TEMP\bootstrap.cmd; & $env:TEMP\bootstrap.cmd"
```

On Windows, you might have to run the bootstrapper once or twice as it adds stuff to the path.

# Bootstrap on Mac

Open Terminal as your normal user (no `sudo`), and copy-paste this command to execute it:
```
curl -fsSL https://raw.githubusercontent.com/mostergaard/dotfiles/refs/heads/main/bootstrap-mac.sh -o "$TMPDIR/bootstrap-mac.sh" && bash "$TMPDIR/bootstrap-mac.sh"
```

The Xcode Command Line Tools and Homebrew installers open if they are missing - complete them and the bootstrapper continues.
Steps that need admin pause and ask you to request it through Self Service+.

## Before leaving the old Mac

- [ ] Copy `~/.ssh` (keys and `config`) - or create new keys and add them to GitHub
- [ ] Copy `~/.aws/config` - not the `sso`/`cli` caches, run `aws sso login` instead
- [ ] Copy `~/.claude/settings.json` and `~/.claude/projects/*/memory/` (memory folders are named after the repo paths, so keep `~/Code`)
- [ ] Re-add the Sourcegraph MCP server, from `~/Code`: `claude mcp add --transport http sg https://siteimprove.sourcegraphcloud.com/.api/mcp`

## Not configured by the bootstrapper

- [ ] Touch ID: System Settings -> Touch ID & Password -> add fingerprints
- [ ] Smaller text: System Settings -> Displays -> pick a resolution towards "More Space"

## Not installed by the bootstrapper

Tools:
- [ ] .NET SDKs (8 and 10) - `.pkg` installers, need admin
- [ ] .NET global tools: `dotnet tool install -g` for `dotnet-ef`, `dotnet-sos`, `dotnet-stack`, `grate`, `ilspycmd`, `datasource.cli`
- [ ] PowerShell - [direct download](https://github.com/MicrosoftDocs/PowerShell-Docs/blob/main/reference/docs-conceptual/install/install-powershell-on-macos.md#install-the-package-via-direct-download), needs admin
- [ ] Postman CLI (`~/.local/bin/postman`)
- [ ] `hyrde` (`~/.local/bin`) and `xgw` (`~/.cargo/bin`)

Apps:
- [ ] 1Password, AltTab, Tiles, Google Chrome, Elgato Stream Deck
- [ ] Slack, Spotify, Signal, WhatsApp
- [ ] Tableau Desktop, Oracle SQL Developer
- [ ] App Store: OneDrive, Microsoft To Do, Universal Print, Copilot, Developer, 1Password for Safari

Expected from IT (Jamf, Self Service+, Company Portal): Office, Teams, Edge, Firefox, Zoom, GitHub Desktop, Zscaler, Defender.