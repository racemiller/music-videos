# README
This contains various scripts to help download and organize music videos.

## music-videos.sh
#### See requirements section for more info
This script does the below:

1. Updates yt-dlp to the latest version
2. Connects to NordVPN
3. Verifies VPN connection
4. Downloads music video from YT in MKV format (paste link)
5. Tries to extract artist/title info from info.json file. If extraction is incorrect, it allows the user to hand-enter the info before proceeding
6. Renames the files to be Plex/Jellyfin friendly
7. Converts the info.json file to an NFO file
8. Ensures the thumbnail is in JPG format
9. Moves the video, thumbnail, and NFO file to your Music Video directory (inside artist subdirectory)
10. Sets permissions on moved files

### Requirements
1. `yt-dlp` [yt-dlp](https://github.com/yt-dlp/yt-dlp)
2. `nordvpn` for Linux (and an account already set up)
3. `ytdl-nfo` [ytdl-nfo](https://github.com/owdevel/ytdl-nfo)
4. `convert`
5. `curl`

### Instructions
1. Install and configure all required packages (see above)
2. Clone the repository (`git clone https://github.com/racemiller/music-videos`)
3. Make the script executable `chmod +x music-videos.sh`
4. Edit the .env file  `nano .env` and set your directories
5. Run the script and follow the instructions `./music-videos.sh`