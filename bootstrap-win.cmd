@echo off

rem This file should be downloaded directly from Github (with something like Curl)
rem to a temporary place and then executed.
rem Find a snippet to do that and put that in a Readme file in this repo.

echo -- Making sure Git and Git Bash is installed...
if not exist "%PROGRAMFILES%\Git\bin\bash.exe" (
    echo Could not find Git and Git Bash. Exiting.
    exit /b 1
	rem TODO: We _could_ at this point try to install Git instead
	rem TODO: In some cases, we've seen that Git was installed not in %PROGRAMFILES%
)

echo. 
echo -- Making sure C:\code exists...
mkdir "C:\code\" 2> NUL
echo. 
pushd C:\code

if not exist "dotfiles" (
	echo -- Checking out the "dotfiles" repo from Github...
	git clone https://github.com/mostergaard/dotfiles.git
	cd dotfiles
) else (
	echo -- Updating the "dotfiles" repo...
	cd dotfiles
	git pull
)

echo.
echo -- Executing the setup script from "dotfiles" in Git Bash...
call "%PROGRAMFILES%\Git\bin\bash.exe" -c './setup-win/setup.sh'

echo.
echo -- Finished bootstrapping on Windows
popd