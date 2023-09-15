#!/bin/bash

echo Configuring Beyond Compare
bc4key_folder="$APPDATA\Scooter Software\Beyond Compare 4"
bc4key_file="$bc4key_folder\BC4Key.txt"
if [ ! -f "$bc4key_file" ]; then
	echo "===> Copy Beyond Compare license key into clipboard and press <enter> to contiue. Hint, the whole key is in my password app!"
	read
	bc4key=$(< /dev/clipboard)
	if [ ! -d "$bc4key_folder" ]; then
	  mkdir -p "$bc4key_folder";
	fi	
	echo "$bc4key" >> "$bc4key_file"
fi
