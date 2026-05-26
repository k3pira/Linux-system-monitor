#!/bin/bash
# ─────────────────────────────────────
# Modulo: CPU Monitor
# Autore: k3pira
# Desc:   Legge utilizzo CPU e load average
# ─────────────────────────────────────

# Colori
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

get_cpu_usage() {
    # Legge la CPU da /proc/stat
    # Calcola la percentuale di utilizzo reale
    local cpu_line=$(grep '^cpu ' /proc/stat)
    local user=$(echo $cpu_line | awk '{print $2}')
    local nice=$(echo $cpu_line | awk '{print $3}')
    local system=$(echo $cpu_line | awk '{print $4}')
    local idle=$(echo $cpu_line | awk '{print $5}')

    # Prima lettura
    local total1=$((user + nice + system + idle))
    local idle1=$idle

    # Aspetta 1 secondo e rilegge
    sleep 1
    cpu_line=$(grep '^cpu ' /proc/stat)
    user=$(echo $cpu_line | awk '{print $2}')
    nice=$(echo $cpu_line | awk '{print $3}')
    system=$(echo $cpu_line | awk '{print $4}')
    idle=$(echo $cpu_line | awk '{print $5}')

    # Seconda lettura
    local total2=$((user + nice + system + idle))
    local idle2=$idle

    # Calcola differenza → percentuale reale
    local diff_total=$((total2 - total1))
    local diff_idle=$((idle2 - idle1))
    local usage=$((100 * (diff_total - diff_idle) / diff_total))

    echo $usage
}

get_load_average() {
    # Load average: quanto lavoro medio negli ultimi 1/5/15 minuti
    cat /proc/loadavg | awk '{print $1, $2, $3}'
}

get_cpu_color() {
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

# Barra di progresso visiva
get_progress_bar() {
    local usage=$1
    local filled=$((usage / 10))
    local empty=$((10 - filled))
    local bar=""

    for ((i=0; i<filled; i++)); do bar+="▓"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done

    echo $bar
}
