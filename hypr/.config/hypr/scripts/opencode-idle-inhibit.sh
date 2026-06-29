#!/usr/bin/env bash

CAELESTIA_IPC="qs -c caelestia ipc call idleInhibitor"

inhibit_active=false

while true; do
    if pgrep -x opencode > /dev/null 2>&1; then
        if [ "$inhibit_active" = false ]; then
            $CAELESTIA_IPC enable
            inhibit_active=true
        fi
    else
        if [ "$inhibit_active" = true ]; then
            $CAELESTIA_IPC disable
            inhibit_active=false
        fi
    fi
    sleep 5
done
