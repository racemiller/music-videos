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
1. Python3
2. NordVPN for Linux (and an account already set up and working with CLI)

### Instructions
1. Install and configure all required packages (see above)
2. Clone the repository (`git clone https://github.com/racemiller/music-videos`)
3. Make the script executable `chmod +x music-videos.sh`
4. Set your directories in the script (`dir` and `mv_dir`) `nano music-videos.sh`
5. Run the script and follow the instructions `./music-videos.sh`