#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")"

function saveFiles() {
	rsync -avh --no-perms ~/.bashrc .
	sed -i "/GITHUB_TOKEN=/c\export GITHUB_TOKEN=SECRET" .bashrc
	sed -i "/DATABASE_PASSWORD=/c\export DATABASE_PASSWORD=SECRET" .bashrc
	sed -i "/REDIS_PASSWORD=/c\export REDIS_PASSWORD=SECRET" .bashrc

	rsync -avh --no-perms ~/.bash_alias .
	rsync -avh --no-perms ~/.bash_functions .
	rsync -avh --no-perms ~/.gitconfig .
	rsync -avh --no-perms ~/.selected_editor .

	mkdir -p .ssh/
	rsync -avh --no-perms ~/.ssh/config .ssh/config

	mkdir -p ./mnt/c/Windows/System32/drivers/etc/
	rsync -avh --no-perms /mnt/c/Windows/System32/drivers/etc/hosts ./mnt/c/Windows/System32/drivers/etc/hosts

	mkdir -p ./mnt/c/Users/Xavier/AppData/Roaming/Code/User/
	rsync -avh --no-perms /mnt/c/Users/Xavier/AppData/Roaming/Code/User/keybindings.json ./mnt/c/Users/Xavier/AppData/Roaming/Code/User/keybindings.json
	rsync -avh --no-perms /mnt/c/Users/Xavier/AppData/Roaming/Code/User/settings.json ./mnt/c/Users/Xavier/AppData/Roaming/Code/User/settings.json

	git add --all
	git commit --message "Save files" --quiet
	git push --quiet
}

saveFiles
unset saveFiles
