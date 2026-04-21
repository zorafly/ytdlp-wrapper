# ytdlp.sh - manager for yt-dlp installations

This script will install and update yt-dlp and it's dependencies for you. It can also fetch media and optionally extract the audio. Fetch commands read URL input from the command line, not as an argument passed to the script. No quoting required.

The script expects a Debian-based environment and is mildly opinionated in it's choice to run apt update/upgrade/autoremove on each "update" invocation. Node.JS is used to solve challenges. The challenge solver scripts, python package builder, and certificate authority bundle are installed in a virtual environment.

If a fetch operation fails, the script will attempt to update and try once more.

## Usage
```
Syntax: ./ytdlp.sh <install|update|audio|video|uninstall>
        install: Install YT-DLP to your home directory
        update: Update YT-DLP and its dependencies
        audio: Fetch media and extract audio, discarding video
        video: Fetch media, keeping both audio and video intact
        uninstall: Remove YT-DLP and its dependencies
```

## Installation
```
$ ./ytdlp.sh install
```

## Example
```
$ ./ytdlp.sh audio
Insert target URL: https://www.youtube.com/watch?v=dQw4w9WgXcQ
...
```

