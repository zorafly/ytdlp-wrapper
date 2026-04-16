#!/usr/bin/env bash

DLPROOT="${HOME}/.local/youtubedl/dlp"

# End of config

url=""
DLP="${DLPROOT}/yt-dlp.sh"
LOCATION="Upstream runscript located at: ${DLP}"

uninstall() {
    echo "This will remove YT-DLP and it's virtual environment."
    echo "This should not remove any content you have downloaded."
    echo -n "Are you sure? [Y/N] "
    read answer
    if [ "$answer" == "y" ] || [ "$answer" == "Y" ]; then
	set -ex
	rm -rf "$DLPROOT"
	set +ex
    fi
}

install() {
    echo -e "\n➜ Installing dependencies...\n"
    set -ex
    sudo apt update
    sudo apt -y install python3 python3-pip virtualenv nodejs
    set +ex
    
    echo -e "\n➜ Cloning YT-DLP...\n"
    set -ex
    mkdir -p "$DLPROOT"
    cd "$DLPROOT"
    git clone https://github.com/yt-dlp/yt-dlp.git .
    set +ex
    
    echo -e "\n➜ Configuring virtual environment...\n"
    set -ex
    virtualenv venv
    source venv/bin/activate
    pip install yt-dlp-ejs certifi build
    set +ex
    
    echo -e "\n➜ Building YT-DLP...\n"
    set -ex
    python3 -m build
    deactivate
    set +ex
    
    echo -e "\n➜ Installation successful."
    echo -e "$LOCATION\n"
}

update() {
    echo -e "\n➜ Updating system...\n"
    set -ex
    sudo apt update
    sudo apt -y upgrade
    sudo apt -y autoremove
    set +ex
    
    echo -e "\n➜ Updating YT-DLP...\n"
    set -ex
    cd "$DLPROOT"
    git pull origin master
    set +ex

    echo -e "\n➜ Updating virtual environment...\n"
    set -ex
    source venv/bin/activate
    pip install -U yt-dlp-ejs certifi build
    set +ex

    echo -e "\n➜ Building YT-DLP...\n"
    set -ex
    python3 -m build
    deactivate
    set +ex

    echo -e "\n➜ Update successful."
    echo "$LOCATION\n"
}

handler2() {
    echo -e "\n!!!"
    echo "Fetch attempt failed with latest code."
    echo "Your content might be DRM protected."
    echo "You may simply have to wait a few days for a YT-DLP update."
    echo "If the issue persists, you can try to open a ticket here:"
    echo -e "\thttps://github.com/yt-dlp/yt-dlp/issues"
    echo "I'm sorry. 😔"
    echo -e "!!!\n"
    exit
}

handler() {
    trap - err
    echo -e "\n!!!"
    echo "Fetch attempt failed. Updating and trying again."
    echo -e "!!!\n"
    update
    trap handler2 err
    fetch "$url"
}

fetch() {
    if [ "$1" == "-x" ]; then
	extract="-x"
    else
	extract="--"
    fi

    # Read URL from the user to ignore quoting shenanigans on the CLI
    if [ -z "$url" ]; then
	echo -en "Insert target URL:"
	read url
	# Extract only the necessary components of the URL
	url="${url%%&*}"
    fi

    # If error occurs, update and try again
    trap handler err
    # Use "ydlarc.txt" in your current directory to keep track of downloads
    base="$PWD"
    archive="${base}/ydlarc.txt"

    echo -e "\n➜ Fetching content...\n"
    cd "${DLPROOT}"
    source venv/bin/activate
    
    # * Use Node.JS to solve challenges 
    # * Keep track of downloads in this file 
    # * Optional audio extraction flag and error ignore flag
    # * Download files to this directory
    # * Target URL
    set -x
    ${DLP}\
	 --js-runtimes node\
	 --download-archive "$archive"\
	 -i\
	 -P "$base"\
	 "$extract"\
	 "$url"
    set +x
    
    deactivate
    echo -e "\nOK\n"
}

syntax() {
    echo "Syntax: $0 <install|update|audio|video|uninstall>"
    echo -e "\tinstall: Install YT-DLP to your home directory"
    echo -e "\tupdate: Update YT-DLP and its dependencies"
    echo -e "\taudio: Fetch media and extract audio, discarding video"
    echo -e "\tvideo: Fetch media, keeping both audio and video intact"
    echo -e "\tuninstall: Remove YT-DLP and its dependencies"
}

case "$1" in
    "uninstall")
	uninstall
	;;
    "install")
	install
	;;
    "update")
	update
	;;
    "audio")
	fetch -x
	;;
    "video")
	fetch
	;;
    *)
	syntax
    ;;
esac

