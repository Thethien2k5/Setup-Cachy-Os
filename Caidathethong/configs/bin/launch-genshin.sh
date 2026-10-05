#!/bin/bash
set -e

# Mount Library partition if not already mounted
GAME_DIR="/run/media/nttdz/Library/HoYoPlay/games/Genshin Impact game"
if [ ! -d "$GAME_DIR" ]; then
    udisksctl mount -b /dev/disk/by-label/Library 2>/dev/null || true
fi

# Execute Genshin Impact through Lutris
exec lutris lutris:rungame/genshin-impact "$@"
