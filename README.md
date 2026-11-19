# Monster Hunter Wilds Save Backup

A small script that copies your Monster Hunter Wilds Steam Cloud save into a dated folder before you play. If a save ever corrupts, or Steam Cloud syncs something you did not want, you have a clean copy to go back to. Versions for Linux (Steam Deck included), macOS, and Windows.

Each time you run it, it finds your current MH Wilds save, copies it to a new timestamped folder under your chosen backup location, then starts the game. Every backup is a full, separate copy, so you can roll back to any point by copying a folder back.

MH Wilds stores its save as a Steam Cloud save, not inside the game folder:

- Linux: `~/.local/share/Steam/userdata/<account>/2246340/remote/`
- Windows: `C:\Program Files (x86)\Steam\userdata\<account>\2246340\remote\`
- macOS: `~/Library/Application Support/Steam/userdata/<account>/2246340/remote/`

`2246340` is the Steam app ID. The script finds the right `<account>` folder for you.

## Key features

- Runs from the game's Steam launch options, so every press of Play makes a backup first.
- Finds your Steam install (native or Flatpak on Linux) and the save folder by scanning `userdata/*/2246340/remote` and picking the account with the newest save.
- Copies with `rsync` on Linux and macOS (falls back to `cp`), and `robocopy` on Windows.
- Names each backup folder by date and time, for example `2026-10-30_21-45-03`.
- A manual run backs up, then launches the game if `LAUNCH_GAME=1`. It skips the launch when the game is already running.
- One line to edit: the backup location.

## Requirements

- Linux: bash, find, rsync or cp, Steam (native or Flatpak).
- macOS: bash, Steam.
- Windows: Windows 10 or 11 (robocopy and PowerShell are built in), Steam.

## Files

- `MH-WILDS_save_backup.sh`: Linux / Steam Deck
- `MH-WILDS_save_backup.command`: macOS
- `MH-WILDS_save_backup.bat`: Windows

## What to edit

One line, the backup location.

Linux / macOS:
```sh
BACKUP_DIR="${BACKUP_DIR:-$HOME/MH-WILDS-Backups}"
```
Windows:
```bat
set "BACKUP_DIR=%USERPROFILE%\MH-WILDS-Backups"
```

Two optional settings sit next to it:

- `STEAM_USER_ID`: leave blank to auto-detect. Set it to a specific Steam account ID if you have more than one and the wrong save gets picked.
- `LAUNCH_GAME`: `1` starts the game after a manual backup, `0` backs up only.

## How to use it

### Steam launch options (backs up every time you press Play)

Right-click the game in Steam, then Properties, General, Launch Options, and paste:

Linux / Steam Deck: put `MH-WILDS_save_backup.sh` in the game folder first (right-click the game, Manage, Browse local files).
```
bash -e "./MH-WILDS_save_backup.sh"; %command%
```
Windows:
```
"C:\full\path\MH-WILDS_save_backup.bat" %command%
```

### Run it manually

- Linux / Steam Deck: `bash MH-WILDS_save_backup.sh`
- macOS: `bash MH-WILDS_save_backup.command`
- Windows: double-click `MH-WILDS_save_backup.bat`

A manual run backs up, then launches the game if `LAUNCH_GAME=1`. It skips the launch when the game is already running.

## Restoring a backup

Close the game. Copy the contents of a backup folder back into the `.../2246340/remote/` path for your system (the paths listed near the top), replacing what is there. Start Steam.

## Compatibility

Steam Deck: works in Desktop Mode. The launch-options method above works the same as on desktop Linux.
