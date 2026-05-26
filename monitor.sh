#!/bin/bash
source config.conf
source modules/cpu.sh
source modules/memory.sh
source modules/disk.sh
source modules/network.sh

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'

clear_screen() { clear; }

write_log() {
    local message=$1
    if [ "$LOG_ENABLED" = "true" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" >> $LOG_FILE
        local lines=$(wc -l < $LOG_FILE)
        if [ $lines -gt $LOG_MAX_LINES ]; then
            tail -n $LOG_MAX_LINES $LOG_FILE > $LOG_FILE.tmp
            mv $LOG_FILE.tmp $LOG_FILE
        fi
    fi
}

print_header() {
    echo -e "${CYAN}${BOLD}"
    echo "  [k3pira@monitor]─────────────────────────────"
    echo -e "${NC}"
    echo -e "   scanning... ${WHITE}$(date '+%Y-%m-%d %H:%M:%S')${NC}"
    echo ""
}

print_cpu() {
    local usage=$(get_cpu_usage)
    local load=$(get_load_average)
    local bar=$(get_progress_bar $usage)
    local color=$(get_cpu_color $usage $CPU_THRESHOLD)
    local status="${GREEN}[OK]${NC}"

    if [ $usage -ge $CPU_THRESHOLD ]; then
        status="${RED}[!!]${NC}"
        write_log "ALERT CPU usage: ${usage}%"
    elif [ $usage -ge 70 ]; then
        status="${YELLOW}[!!]${NC}"
    fi

    echo -e "   ${WHITE}CPU${NC}  [${color}${bar}${NC}] ${color}${usage}%${NC}  ${status}"
    echo -e "   ${WHITE}LDA${NC}  ${load}"
}

print_memory() {
    local mem_data=$(get_memory_usage)
    local usage=$(echo $mem_data | cut -d'|' -f1)
    local used=$(echo $mem_data | cut -d'|' -f2)
    local total=$(echo $mem_data | cut -d'|' -f3)
    local bar=$(get_progress_bar $usage)
    local color=$(get_memory_color $usage $RAM_THRESHOLD)
    local status="${GREEN}[OK]${NC}"

    if [ $usage -ge $RAM_THRESHOLD ]; then
        status="${RED}[!!]${NC}"
        write_log "ALERT RAM usage: ${usage}%"
    elif [ $usage -ge 70 ]; then
        status="${YELLOW}[!!]${NC}"
    fi

    local swap_data=$(get_swap_usage)
    local swap_used=$(echo $swap_data | cut -d'|' -f2)
    local swap_total=$(echo $swap_data | cut -d'|' -f3)

    echo -e "   ${WHITE}RAM${NC}  [${color}${bar}${NC}] ${color}${usage}%${NC}  ${status}"
    echo -e "   ${WHITE}MEM${NC}  ${used}MB / ${total}MB"
    echo -e "   ${WHITE}SWP${NC}  ${swap_used}MB / ${swap_total}MB"
}

print_disk() {
    get_disk_usage | while IFS='|' read mount usage used total; do
        local bar=$(get_progress_bar $usage)
        local color=$(get_disk_color $usage $DISK_THRESHOLD)
        local status="${GREEN}[OK]${NC}"

        if [ $usage -ge $DISK_THRESHOLD ]; then
            status="${RED}[!!]${NC}"
        elif [ $usage -ge 70 ]; then
            status="${YELLOW}[!!]${NC}"
        fi

        echo -e "   ${WHITE}DSK${NC}  [${color}${bar}${NC}] ${color}${usage}%${NC}  ${status}  ${mount} (${used}/${total})"
    done
}

print_network() {
    local status=$(get_interface_status $NET_INTERFACE)
    local ip=$(get_local_ip $NET_INTERFACE)
    local net_data=$(get_network_usage $NET_INTERFACE)
    local rx=$(echo $net_data | cut -d'|' -f1)
    local tx=$(echo $net_data | cut -d'|' -f2)
    local status_color=$GREEN
    local status_label="[UP]"

    if [ "$status" = "DOWN" ]; then
        status_color=$RED
        status_label="[DOWN]"
    fi

    echo -e "   ${WHITE}NET${NC}  ${NET_INTERFACE} ↓${rx}KB/s ↑${tx}KB/s  ${status_color}${status_label}${NC}"
    echo -e "   ${WHITE}IP ${NC}  ${ip}"
}

print_footer() {
    echo ""
    echo -e "   ${CYAN}─────────────────────────────────────────────${NC}"

    if grep -q "ALERT" $LOG_FILE 2>/dev/null; then
        local last_alert=$(grep ALERT $LOG_FILE | tail -1)
        echo -e "   ${RED}STATUS >> ${last_alert}${NC}"
    else
        echo -e "
${GREEN}STATUS >> ALL SYSTEMS NOMINAL${NC}"
    fi

    echo ""
    echo -e "   ${WHITE}refresh: ${MONITOR_INTERVAL}s — CTRL+C to exit${NC}"
    echo ""
}

main() {
    mkdir -p logs
    touch $LOG_FILE
    write_log "Monitor avviato"

    while true; do
        clear_screen
        print_header
        print_cpu
        echo ""
        print_memory
        echo ""
        print_disk
        echo ""
        print_network
        print_footer
        sleep $MONITOR_INTERVAL
    done
}

main
