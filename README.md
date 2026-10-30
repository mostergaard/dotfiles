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