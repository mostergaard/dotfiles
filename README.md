# Bootstrap on Windows

Open a new Windows terminal IN ADMIN, and copy-paste this command to execute it:
```
powershell -c "iwr -useb https://raw.githubusercontent.com/mostergaard/dotfiles/refs/heads/main/bootstrap-win.cmd -OutFile $env:TEMP\bootstrap.cmd; & $env:TEMP\bootstrap.cmd"
```

On Windows, you might have to run the bootstrapper once or twice as it adds stuff to the path. 