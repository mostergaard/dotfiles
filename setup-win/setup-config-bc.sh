#!/bin/bash

echo Configuring Beyond Compare
bc5key_folder="$APPDATA\Scooter Software\Beyond Compare 5"
bc5key_file="$bc5key_folder\BC5Key.txt"
if [ ! -f "$bc5key_file" ]; then
	echo "===> Copy Beyond Compare license key (BC5 PRO) into clipboard and press <enter> to contiue. Hint, the whole key is in my password app!"
	read
	bc5key=$(< /dev/clipboard)
	if [ ! -d "$bc5key_folder" ]; then
	  mkdir -p "$bc5key_folder";
	fi	
	echo "$bc5key" >> "$bc5key_file"
fi
