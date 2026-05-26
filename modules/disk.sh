#!/bin/bash
# ─────────────────────────────────────
# Modulo: Disk Monitor
# Autore: k3pira
# Desc:   Legge utilizzo disco
# ─────────────────────────────────────

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

get_disk_usage() {
    # df legge lo spazio disco di ogni partizione
    # -h = human readable, -x = esclude filesystem virtuali
    df -h -x tmpfs -x devtmpfs | tail -n +2 | while read line; do
        local mount=$(echo $line | awk '{print $6}')
        local usage=$(echo $line | awk '{print $5}' | tr -d '%')
        local used=$(echo $line | awk '{print $3}')
        local total=$(echo $line | awk '{print $2}')

        echo "$mount|$usage|$used|$total"
    done
}

get_disk_color() {
    local usage=$1
    local threshold=$2

    if [ $usage -ge $threshold ]; then
        echo $RED
    elif [ $usage -ge 70 ]; then
        echo $YELLOW
    else
        echo $GREEN
    fi
}

get_progress_bar() {
    local usage=$1
    local filled=$((usage / 10))
    local empty=$((10 - filled))
    local bar=""

    for ((i=0; i<filled; i++)); do bar+="▓"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done

    echo $bar
}
