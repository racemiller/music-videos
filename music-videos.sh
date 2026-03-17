#!/bin/bash

## Directories - be sure to set these before running the script!!
dir="/path/ to/ tmp/ directory/" # This is where downloads will initially go
mv_dir="/path/ to/ music/ video/ directory/" # This is where processed music videos will end up

## Ensure dependencies - Note: will only work on debian based systems with Python3 installed.
pipx="$(which pipx)"
imagemagick="$(which convert)"
yt_dlp="$(which yt-dlp)"
ytdl_nfo="$(which ytdl-nfo)"

if [[ ! -n $pipx ]]; then
    echo "installing pipx"
    sudo apt-get install pipx -y
else
    echo "pipx already installed"
fi
if [[ ! -n $imagemagick ]]; then
    echo "installing imagemagick"
    sudo apt-get install imagemagick -y
else
    echo "imagemagick already installed"
fi
if [[ ! -n $yt_dlp ]]; then
    echo "installing yt-dlp"
    pipx install yt-dlp
else
    echo "yt-dlp already installed"
fi
if [[ ! -n $ytdl_nfo ]]; then
    echo "installing ytdl-nfo"
    pipx install ytdl-nfo
    source /home/$(whoami)/.local/share/pipx/venvs/ytdl-nfo/bin/activate
    python -m pip install "setuptools<82"
    deactivate
else
    echo "ytdl-nfo already installed"
fi

function pause(){
  read -s -n 1 -p "Press any key to continue . . ."
  echo ""
}

## Feel free to uncomment any 'pause' that you would like to add.

ip1=$(curl -s https://ipinfo.io/ip)

## Update yt-dlp
pipx upgrade yt-dlp

echo "Paste YT URL:"
read url

## Connect to VPN - remove this section and 'nordvpn d' if you want to use this script without a VPN
nordvpn c
ip2=$(curl -s https://ipinfo.io/ip)
if [ "$ip1" = "$ip2" ]; then
    echo "VPN connection failed. Please check your VPN settings and try again."
    exit 1
else
    echo "VPN connection successful. Proceeding with download..."
fi

## Adjust yt-dlp settings as necessary. Note, --write-thumbnail, --write-info-json, --paths "$dir", -t mkv, and -o "%(title)s-video.%(ext)s" are required for the script to function.
yt-dlp \
--extractor-args "youtube:player-client=default,-tv_simply" \
--limit-rate 10M \
--throttled-rate 100K \
--embed-thumbnail \
--write-thumbnail \
--format-sort "codec:vp9" \
--embed-subs \
--embed-metadata \
--write-info-json \
--paths "$dir" \
-t mkv \
-o "%(title)s-video.%(ext)s" \
$url

nordvpn d

# pause
json="$(find "$dir" -maxdepth 1 -type f -name "*-video.info.json")"

## Extract metadata from info.json file
full_title=$(cat "$json" | jq -r '.fulltitle')
parsed=$(echo "$full_title" | sed -E 's/^(.*?) - ([^([]*).*$/\1|\2/')
artist="${parsed%%|*}"
title="${parsed#*|}"
title=$(echo "$title" | sed -E "s/[[:space:]]+$//; s/ *'[^ ]+$//")


## Sanity checks before renaming/moving
base="${json%.info.json}"

if [ ! -f "$base.mkv" ]; then
    echo "Video file not found. Exiting"
    exit
else
    echo "Found video file"
    ## Fixes yt-dlp special character handling
    mv -v "$json" "$full_title-video.info.json"
    mv -v "$base.mkv" "$full_title-video.mkv"
    [[ -f "$base.webp" ]] && mv -v "$base.webp" "$dir/$full_title-video.webp"
    [[ -f "$base.jpg" ]] && mv -v "$base.jpg" "$dir/$full_title-video.jpg"
fi
if [ ! -n "$artist" ]; then
    echo "Video artist not found. Exiting"
    exit
else
    while true; do
        echo "Artist: $artist"
        read -p "Artist correct? (y/n): " yn
        case $yn in
            [Yy]* ) echo "Proceeding..."; break;;
            [Nn]* ) echo "Enter artist name"; read artist;;
            * ) echo "Invalid response, please answer yes or no.";; # Handle all other invalid inputs
        esac
    done
fi
    if [ ! -n "$title" ]; then
    echo "Video title not found. Exiting"
    exit
else
    while true; do
        echo "Title: $title"
        read -p "Title correct? (y/n): " yn
        case $yn in
            [Yy]* ) echo "Proceeding..."; break;;
            [Nn]* ) echo "Enter title"; read title;;
            * ) echo "Invalid response, please answer yes or no.";; # Handle all other invalid inputs
        esac
    done
fi

# pause

## Create directories if needed
if [ ! -d "$dir" ]; then
    mkdir -pv "$dir"
fi
if [ ! -d "$mv_dir/$artist" ]; then
    mkdir -pv "$mv_dir/$artist"
fi

## Rename files to match title
mv -v "$dir/$full_title-video.mkv" "$dir/$title-video.mkv"
[[ -f "$dir/$full_title-video.webp" ]] && mv -v "$dir/$full_title-video.webp" "$dir/$title-video.webp"
[[ -f "$dir/$full_title-video.jpg" ]] && mv -v "$dir/$full_title-video.jpg" "$dir/$title-video.jpg"
mv -v "$dir/$full_title-video.info.json" "$dir/$title-video.info.json"

# pause

## Write nfo file
ytdl-nfo "$dir/$title-video.info.json"
rm -v "$dir/$title-video.info.json"

# pause

## Convert thumbnail to jpg
if [[ -f "$dir/$title-video.webp" ]]; then
    convert -verbose "$dir/$title-video.webp" "$dir/$title-video.jpg"
    rm -v "$dir/$title-video.webp"
fi

# pause

## Move files to correct location
mv -v "$dir/$title-video.mkv" "$mv_dir/$artist/$title-video.mkv"
mv -v "$dir/$title-video.jpg" "$mv_dir/$artist/$title-video.jpg"
mv -v "$dir/$title-video.nfo" "$mv_dir/$artist/$title-video.nfo"

# pause

## Set permissions
chmod -v 666 "$mv_dir/$artist/$title"*