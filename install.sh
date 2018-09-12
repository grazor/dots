#!/bin/bash

PRETEND=false

INSTALL=true
INSTALL_CMD=${INSTALL_CMD:-yaourt -S --noconfirm}

ROOT_PATH=$(dirname $(readlink -f "$0"))
PROJECTS_PATH="$ROOT_PATH/projects.ini"

getprojects () {
	sep=${1:-" "}
	sed -nr "/^[^[].*$/d; s/\[(.*)\]/\1/p" "$PROJECTS_PATH" | tr '\n' "$sep"
}

getopt () {
	sed -nr "/^\[$1\]/ { :l /^$2[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" "$PROJECTS_PATH"
}

install () {
	project=$1

	echo "* Installing project $project"
	echo "  ├── info: $(getopt $project info)" 

	########
	# Step 1. copy configs uing stow
	dest=$(getopt $project root)
	dest="${dest/#\~/$HOME}"
	echo "  ├─> copying configs to $dest"
	action="stow -t $dest $project"
	[ $PRETEND = false ] && $action || echo "  ├── $action"
	echo "  ├─= done"

	########
	# Step 2. install requirements, optional
	if [ $INSTALL = true ] ; then
		echo "  ├─> installing required packages"
		action="$INSTALL_CMD $(getopt $project packages)"
		[ $PRETEND = false ] && $action || echo "  ├── $action"
		echo "  ├─= done"
	else
		echo "  ├─= skipping requirements"
	fi

	########
	# Step 3. run post-install script
	script=$(getopt $project post-install)
	if [[ ! -z ${script// } ]] ; then
		script="$ROOT_PATH/post-install/$script"
		echo "  ├─> executing post-install $script"
		action="bash $script"
		[ $PRETEND = false ] && $action || echo "  ├── $action"
	else
		echo "  ├─= no post-install script specified"
	fi

	echo "  └── project $1 installed"
	echo
}

process () {
	if [ $INSTALL = true ] ; then
		echo "BEWARE! Required packages will be installed using command:"
		echo $INSTALL_CMD
		echo "You can overwrite this command by setting INSTALL_CMD= env var"
		echo "Or using --command parameter"
	else
		echo "Required packages will not be installed!"
	fi

	echo
	echo "Choose projects to istall: 'all' or space separated list of names"
	echo "Avaliable projects: $(getprojects ',')"
	echo "[1] e.g. '> all'"
	echo "[2] e.g. '> i3'"
	echo "[3] e.g. '> term i3 emacs'"
	echo -n "> "
	read choice

	[ "$choice" = "all" ] && choice=$(getprojects)
	for project in $choice ; do
		install $project
	done
}

process
