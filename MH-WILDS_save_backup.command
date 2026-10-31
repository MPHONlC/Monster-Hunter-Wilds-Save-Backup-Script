#!/usr/bin/env bash
#
# Monster Hunter Wilds - Save Backup (macOS)
# By APHONIC
#
# Copies your Monster Hunter Wilds Steam Cloud save into a timestamped folder,
# then launches the game. It finds your Steam install, your account and the
# save folder on its own.
#
# Edit BACKUP_DIR below to choose where backups go. Everything else auto-detects.
# Set STEAM_USER_ID only to force a specific Steam account.
#
# Two ways to run it:
#   1. Steam launch options (backs up every time you press Play, then starts the game):
#        "/full/path/MH-WILDS_save_backup.command" %command%
#   2. Manually: double-click the file, or run
#        bash MH-WILDS_save_backup.command

WINDOW_TITLE="Monster Hunter Wilds Save Backup Script By APHONIC"

BACKUP_DIR="${BACKUP_DIR:-$HOME/MH-WILDS-Backups}"
#BACKUP_DIR="/your/backup/location"

GAME_ID="${GAME_ID:-2246340}"
GAME_NAME="${GAME_NAME:-Monster Hunter Wilds}"
GAME_PROCESS="${GAME_PROCESS:-MonsterHunterWilds}"
STEAM_USER_ID="${STEAM_USER_ID:-}"
LAUNCH_GAME="${LAUNCH_GAME:-1}"


set -uo pipefail

set_title() { [ -t 1 ] || return 0; printf '\033]0;%s\007' "$WINDOW_TITLE"; }
say() { printf '%s\n' "$*"; }
warn() { printf '\n[!] %s\n' "$*" >&2; }
pause() { [ -t 0 ] || return 0; printf '%s' "${1:-Press a key to close...}"; read -rt "${2:-10}" -n1 _ 2>/dev/null; printf '\n'; }
die() { warn "$*"; pause "Press a key to close..." 20; exit 1; }

steam_roots() {
    local c real seen=""
    for c in \
        "$HOME/Library/Application Support/Steam" \
        "$HOME/Library/Application Support/Steam/Steam"
    do
        [ -d "$c/userdata" ] || continue
        real="$(cd "$c" 2>/dev/null && pwd -P)" || continue
        case ":$seen:" in *":$real:"*) continue ;; esac
        seen="$seen:$real"
        printf '%s\n' "$real"
    done
}

newest_mtime() {
    local t
    t="$(find "$1" -type f -exec stat -f '%m' {} + 2>/dev/null | sort -rn | head -n1)"
    printf '%s\n' "${t:-0}"
}

find_save_dir() {
    local root d best="" best_t=0 t
    while IFS= read -r root; do
        if [ -n "$STEAM_USER_ID" ]; then
            d="$root/userdata/$STEAM_USER_ID/$GAME_ID/remote"
            if [ -d "$d" ] && [ -n "$(ls -A "$d" 2>/dev/null)" ]; then
                printf '%s\n' "$d"
                return 0
            fi
            continue
        fi
        for d in "$root"/userdata/*/"$GAME_ID"/remote; do
            { [ -d "$d" ] && [ -n "$(ls -A "$d" 2>/dev/null)" ]; } || continue
            t="$(newest_mtime "$d")"
            if [ "$t" -ge "$best_t" ]; then best_t="$t"; best="$d"; fi
        done
    done < <(steam_roots)
    [ -n "$best" ] && printf '%s\n' "$best"
}

copy_save() {
    if command -v rsync >/dev/null 2>&1; then
        rsync -a "$1"/ "$2"/
    else
        cp -a "$1"/. "$2"/
    fi
}

game_running() { pgrep -f -- "$GAME_PROCESS" >/dev/null 2>&1; }

launch_game() {
    if game_running; then
        say "Game is already running, not launching it again."
        return 0
    fi
    say "Launching $GAME_NAME..."
    open "steam://rungameid/$GAME_ID" >/dev/null 2>&1 || \
        say "Could not open Steam to launch the game. Start it yourself."
}

do_backup() {
    command -v find >/dev/null 2>&1 || { warn "'find' is required but was not found."; return 1; }

    say "$GAME_NAME - save backup"
    say "=============================="

    local src
    src="$(find_save_dir)"
    if [ -z "$src" ]; then
        warn "No save found for app $GAME_ID under any Steam userdata folder.
Check that the game is installed and has saved at least once (Steam Cloud synced).
If the save is under a different Steam account, set STEAM_USER_ID near the top."
        return 1
    fi

    say ""
    say "Save folder:"
    say "  $src"

    local ts dest
    ts="$(date +%Y-%m-%d_%H-%M-%S)"
    dest="$BACKUP_DIR/$ts"
    mkdir -p "$dest" || { warn "Could not create the backup folder: $dest"; return 1; }

    say ""
    say "Backing up..."
    if ! copy_save "$src" "$dest"; then
        rmdir "$dest" 2>/dev/null
        warn "Copy failed, nothing was backed up."
        return 1
    fi
    say "Backup saved here:"
    say "  $dest"
    return 0
}

main() {
    set_title

    if [ "$#" -gt 0 ]; then
        do_backup || warn "Launching the game anyway."
        exec "$@"
    fi

    do_backup || die "Backup did not complete."

    if [ "$LAUNCH_GAME" = "1" ]; then
        say ""
        launch_game
    fi

    say ""
    say "Done."
    pause "Closing in 10s (press a key)..." 10
}

main "$@"
