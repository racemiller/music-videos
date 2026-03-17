#!/bin/bash

source .env

## Ensure dependencies - Note: will only work on debian based systems with Python3 installed.
sudo apt-get install pipx curl imagemagick -y
pipx install yt-dlp
pipx install ytdl-nfo


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

## Extract metadata from info.json file
full_title=$(cat $dir/*-video.info.json | jq -r '.fulltitle')
parsed=$(echo "$full_title" | sed -E 's/^(.*?) - ([^([]*).*$/\1|\2/')
artist="${parsed%%|*}"
title="${parsed#*|}"
title=$(echo "$title" | sed -E 's/^(.*?) - ([^([]*?)( (ft\.|feat\.).*)?(\(|\[).*/\1|\2/I')
title=$(echo "$title" | sed -E "s/[[:space:]]+$//; s/ *'[^ ]+$//")


## Sanity checks before renaming/moving
if [ ! -e "$full_title-video.mkv" ]; then
    echo "Video file not found. Exiting"
    exit
else
    echo "Found video file"
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
    mkdir -p "$dir"
fi
if [ ! -d "$mv_dir/$artist" ]; then
    mkdir -p "$mv_dir/$artist"
fi    

## Rename files to match title
mv -v "$dir/$full_title-video.mkv" "$dir/$title-video.mkv"
mv -v "$dir/$full_title-video.webp" "$dir/$title-video.webp"
mv -v "$dir/$full_title-video.info.json" "$dir/$title-video.info.json"

# pause

## Write nfo file
ytdl-nfo "$dir/$title-video.info.json"
rm -v "$dir/$title-video.info.json"

# pause

## Convert thumbnail to jpg
convert -verbose "$dir/$title-video.webp" "$dir/$title-video.jpg"
rm -v "$dir/$title-video.webp"

# pause

## Move files to correct location
mv -v "$dir/$title-video.mkv" "$mv_dir/$artist/$title-video.mkv"
mv -v "$dir/$title-video.jpg" "$mv_dir/$artist/$title-video.jpg"
mv -v "$dir/$title-video.nfo" "$mv_dir/$artist/$title-video.nfo"

# pause

## Set permissions
chmod -v 666 "$mv_dir/$artist/$title"*