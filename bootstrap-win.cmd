@echo off

rem This file should be downloaded directly from Github (with something like Curl)
rem to a temporary place and then executed.
rem Find a snippet to do that and put that in a Readme file in this repo.

echo -- Installing the latest Git...
echo. 
winget install --id Git.Git -e --source winget

echo. 
echo -- Making sure Git Bash is installed...
echo. 
if not exist "%LOCALAPPDATA%\Programs\Git\bin\bash.exe" (
	echo Could not find Git and Git Bash. Exiting.
	exit /b 1
)

echo. 
echo -- Making sure C:\code exists...
echo. 
mkdir "C:\code\" 2> NUL
pushd C:\code

if not exist "dotfiles" (
	echo. 
	echo -- Checking out the "dotfiles" repo from Github...
	echo. 
	git clone https://github.com/mostergaard/dotfiles.git
	cd dotfiles
) else (
	echo. 
	echo -- Updating the "dotfiles" repo...
	echo. 
	cd dotfiles
	git pull
)

echo.
echo -- Executing the setup script from "dotfiles" in Git Bash...
echo.
call "%LOCALAPPDATA%\Programs\Git\bin\bash.exe" -c './setup-win/setup.sh'

echo.
echo -- Finished bootstrapping on Windows
echo.
popd