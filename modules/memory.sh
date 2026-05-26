#!/bin/bash
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

get_memory_usage() {
    local total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    local available=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
    local used=$((total - available))
    local total_mb=$((total / 1024))
    local used_mb=$((used / 1024))
    local free_mb=$((available / 1024))
    local usage=$((100 * used / total))
    echo "$usage|$used_mb|$total_mb|$free_mb"
}

get_swap_usage() {
    local total=$(grep SwapTotal /proc/meminfo | awk '{print $2}')
    local free=$(grep SwapFree /proc/meminfo | awk '{print $2}')
    local used=$((total - free))
    if [ $total -eq 0 ]; then echo "0|0|0"; return; fi
    local total_mb=$((total / 1024))
    local used_mb=$((used / 1024))
    local usage=$((100 * used / total))
    echo "$usage|$used_mb|$total_mb"
}

get_memory_color() {
    local usage=$1
    local threshold=$2
    if [ $usage -ge $threshold ]; then echo $RED
    elif [ $usage -ge 70 ]; then echo $YELLOW
    else echo $GREEN
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
