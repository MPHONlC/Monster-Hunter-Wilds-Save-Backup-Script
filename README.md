# Monster Hunter Wilds Save Backup

A small script that copies your Monster Hunter Wilds Steam Cloud save into a dated folder before you play. If a save ever corrupts, or Steam Cloud syncs something you did not want, you have a clean copy to go back to. Versions for Linux (Steam Deck included), macOS, and Windows.

## What it does

Each time you run it, it finds your current MH Wilds save, copies it to a new timestamped folder under your chosen backup location, then starts the game. Every backup is a full, separate copy, so you can roll back to any point by copying a folder back.

MH Wilds stores its save as a Steam Cloud save, not inside the game folder:

- Linux: `~/.local/share/Steam/userdata/<account>/2246340/remote/`
- Windows: `C:\Program Files (x86)\Steam\userdata\<account>\2246340\remote\`
- macOS: `~/Library/Application Support/Steam/userdata/<account>/2246340/remote/`

`2246340` is the Steam app ID. The script finds the right `<account>` folder for you.

## Files

- `MH-WILDS_save_backup.sh` — Linux / Steam Deck
- `MH-WILDS_save_backup.command` — macOS
- `MH-WILDS_save_backup.bat` — Windows

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

- `STEAM_USER_ID` — leave blank to auto-detect. Set it to a specific Steam account ID if you have more than one and the wrong save gets picked.
- `LAUNCH_GAME` — `1` starts the game after a manual backup, `0` backs up only.

## How to use it

### Steam launch options (backs up every time you press Play)

Right-click the game in Steam, then Properties, General, Launch Options, and paste:

Linux / Steam Deck:
```
"/full/path/MH-WILDS_save_backup.sh" %command%
```
macOS:
```
"/full/path/MH-WILDS_save_backup.command" %command%
```
Windows:
```
"C:\full\path\MH-WILDS_save_backup.bat" %command%
```

On Linux and macOS, mark the file executable once:
```sh
chmod +x MH-WILDS_save_backup.sh
```

Now Steam runs the backup first, then hands off to the game when you press Play. If the backup fails for any reason, the game still starts, so it never blocks you.

### Run it manually

- Linux / Steam Deck: `bash MH-WILDS_save_backup.sh`
- macOS: double-click `MH-WILDS_save_backup.command`, or run `bash MH-WILDS_save_backup.command`
- Windows: double-click `MH-WILDS_save_backup.bat`

A manual run backs up, then launches the game if `LAUNCH_GAME=1`. It skips the launch when the game is already running.

## How it works

- Finds your Steam install (native or Flatpak on Linux) and the save folder by scanning `userdata/*/2246340/remote` and picking the account with the newest save.
- Copies with `rsync` on Linux and macOS (falls back to `cp`), and `robocopy` on Windows.
- Names each backup folder by date and time, for example `2026-10-30_21-45-03`.

## Steam Deck

Works in Desktop Mode. Double-clicking a `.sh` opens a text editor instead of running it, so run it from a terminal (Konsole), add it as a non-Steam game, or use the launch-options method above, which works the same as on desktop Linux.

## Restoring a backup

Close the game. Copy the contents of a backup folder back into the `.../2246340/remote/` path for your system (the paths listed near the top), replacing what is there. Start Steam.

## Requirements

- Linux: bash, find, rsync or cp, Steam (native or Flatpak).
- macOS: bash, Steam.
- Windows: Windows 10 or 11 (robocopy and PowerShell are built in), Steam.

## Notes

Monster Hunter Wilds runs on Windows and Linux. The macOS version isn't fully tested for crossover report any bugs; it reports if no save is present.
