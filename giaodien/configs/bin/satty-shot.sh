#!/usr/bin/env bash
export LC_ALL=C.UTF-8

REGION=$(slurp)

if [ -n "$REGION" ]; then
    TMP_IMG="/tmp/satty_shot.png"
    
    grim -g "$REGION" "$TMP_IMG"

    if [ -f "$TMP_IMG" ]; then
        wl-copy -t image/png < "$TMP_IMG"

        satty -f "$TMP_IMG" \
            --copy-command "wl-copy -t image/png" \
            --early-exit copy \
            --actions-on-enter "save-to-clipboard,exit" \
            --disable-notifications
    fi
fi
