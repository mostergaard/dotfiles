@echo off

rem This file should be downloaded directly from Github (with something like Curl)
rem to a temporary place and then executed.
rem Find a snippet to do that and put that in a Readme file in this repo.

rem TODO: Detect if git is installed and fail if not...

echo Making sure C:\code exists...
mkdir "C:\code\" 2> NUL
echo. 
pushd C:\code

if not exist "dotfiles" (
	echo Checking out the "dotfiles" repo from Github...
	git clone https://github.com/mostergaard/dotfiles.git
	cd dotfiles
) else (
	echo Updating the "dotfiles" repo...
	cd dotfiles
	git pull
)

echo.
echo Executing the setup script from "dotfiles"...
cd setup-win
call setup.cmd

echo.
echo Finished bootstrapping on Windows
popd