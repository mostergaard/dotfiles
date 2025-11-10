# Bootstrap on Windows

Open a new Windows terminal and copy-paste this command to execute it:
```
powershell -c "iwr -useb https://raw.githubusercontent.com/mostergaard/dotfiles/refs/heads/main/bootstrap-win.cmd -OutFile $env:TEMP\bootstrap.cmd; & $env:TEMP\bootstrap.cmd"
```