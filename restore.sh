#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")"

function restoreFiles() {
	rsync -avh --no-perms ./.bashrc ~/
	rsync -avh --no-perms ./.bash_alias ~/
	rsync -avh --no-perms ./.bash_functions ~/
	rsync -avh --no-perms ./.gitconfig ~/
	rsync -avh --no-perms ./.selected_editor ~/

	rsync -avh --no-perms ./.ssh/config ~/.ssh/config

	rsync -avh --no-perms ./mnt/c/Windows/System32/drivers/etc/hosts /mnt/c/Windows/System32/drivers/etc/hosts

	rsync -avh --no-perms ./mnt/c/Users/Xavier/AppData/Roaming/Code/User/keybindings.json /mnt/c/Users/Xavier/AppData/Roaming/Code/User/keybindings.json
	rsync -avh --no-perms ./mnt/c/Users/Xavier/AppData/Roaming/Code/User/settings.json /mnt/c/Users/Xavier/AppData/Roaming/Code/User/settings.json
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
	restoreFiles;
else
	read -p "This may overwrite existing files! Are you sure? (y/n) " -n 1;
	echo "";
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		restoreFiles;
	fi;
fi;
unset restoreFiles
