# [k3pira] Linux System Monitor

> Real-time Linux system monitoring tool — built from scratch in Bash

![Bash](https://img.shields.io/badge/Bash-4EAA25?style=flat&logo=gnubash&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=flat&logo=linux&logoColor=black)
![License](https://img.shields.io/badge/License-MIT-blue.svg)

## Overview

Lightweight system monitor built in pure Bash.
Monitors CPU, RAM, disk and network in real-time directly from the terminal.
No external dependencies — uses only Linux kernel interfaces.

## Features

- Real-time CPU usage with load average
- RAM and SWAP monitoring
- Disk usage for all partitions
- Network interface status, IP, upload/download speed
- Color-coded alerts (green/yellow/red)
- Automatic logging with timestamp
- Fully configurable via config file

## Stack

- Bash
- Linux kernel interfaces (/proc/stat, /proc/meminfo, /proc/net/dev)
- No external dependencies

## Installation

```bash
git clone https://github.com/k3pira/linux-system-monitor.git
cd linux-system-monitor
chmod +x monitor.sh modules/*.sh
```

## Configuration

Edit `config.conf` to customize thresholds and settings:

```bash
CPU_THRESHOLD=80      # Alert when CPU exceeds this %
RAM_THRESHOLD=80      # Alert when RAM exceeds this %
DISK_THRESHOLD=90     # Alert when disk exceeds this %
MONITOR_INTERVAL=5    # Refresh interval in seconds
NET_INTERFACE=wlan0   # Network interface to monitor
LOG_ENABLED=true      # Enable/disable logging
```

## Usage

```bash
./monitor.sh
```

Press `CTRL+C` to exit.

## Output

[k3pira@monitor]─────────────────────────────
scanning... 2026-05-26 17:02:51
CPU  [▓░░░░░░░░░]  5%  [OK]
LDA  1.85 1.81 1.60
RAM  [▓▓░░░░░░░░] 22%  [OK]
MEM  3502MB / 15726MB
SWP  0MB / 2585MB
DSK  [▓▓▓▓▓▓░░░░] 65%  [OK]  / (28G/45G)
NET  wlan0 ↓0KB/s ↑0KB/s  [UP]
IP   192.168.1.9
─────────────────────────────────────────────
STATUS >> ALL SYSTEMS NOMINAL
refresh: 5s — CTRL+C to exit

## Future Improvements

- [ ] Network scanner — detect all devices on LAN
- [ ] Evil Twin detector
- [ ] Process monitor — detect suspicious processes
- [ ] Email/Telegram alerts
- [ ] Web dashboard

## Author

**k3pira** — [github.com/k3pira](https://github.com/k3pira)

## License

MIT
