#!/bin/bash
# ─────────────────────────────────────
# Modulo: Network Monitor
# Autore: k3pira
# Desc:   Legge traffico di rete
# ─────────────────────────────────────

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

get_network_usage() {
    local interface=$1

    # /proc/net/dev contiene statistiche rete live
    local rx1=$(grep $interface /proc/net/dev | awk '{print $2}')
    local tx1=$(grep $interface /proc/net/dev | awk '{print $10}')

    # Aspetta 1 secondo e rilegge
    sleep 1

    local rx2=$(grep $interface /proc/net/dev | awk '{print $2}')
    local tx2=$(grep $interface /proc/net/dev | awk '{print $10}')

    # Calcola differenza = bytes al secondo
    local rx_speed=$((rx2 - rx1))
    local tx_speed=$((tx2 - tx1))

    # Converti in KB/s
    local rx_kb=$((rx_speed / 1024))
    local tx_kb=$((tx_speed / 1024))

    echo "$rx_kb|$tx_kb"
}

get_interface_status() {
    local interface=$1

    # Controlla se interfaccia è UP o DOWN
    local state=$(cat /sys/class/net/$interface/operstate 2>/dev/null)

    if [ "$state" = "up" ] || [ "$state" = "dormant" ]; then
        echo "UP"
    else
        echo "DOWN"
    fi
}

get_local_ip() {
    local interface=$1
    # Legge l'IP locale dell'interfaccia
    ip addr show $interface 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d/ -f1
}
