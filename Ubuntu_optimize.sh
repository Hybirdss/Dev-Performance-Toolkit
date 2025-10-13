#!/usr/bin/env bash
# =========================================================
# Ubuntu 24.04 Hyper Optimization Script
# Author: Hybirdss (oinkm@naver.com)
# Purpose: Optimize CPU, I/O, Network, Memory, Boot, Docker, VSCode for dev & AI workloads
# Usage:
#   chmod +x ubuntu_optimize.sh && sudo ./ubuntu_optimize.sh
# =========================================================

set -euo pipefail

log(){ echo -e "\033[1;36m[OPTIMIZE]\033[0m $*"; }
backup(){ [ -f "$1" ] && cp -a "$1" "$1.bak.$(date +%Y%m%d%H%M%S)"; }
append_unique(){ local LINE="$1" FILE="$2"; grep -qxF "$LINE" "$FILE" || echo "$LINE" >> "$FILE"; }

[[ $EUID -eq 0 ]] || { echo "Run as root."; exit 1; }

log "1️⃣ CPU & Power Management"
apt install -y cpufrequtils irqbalance tuned
cpufreq-set -g performance || true
systemctl enable --now irqbalance || true
tuned-adm profile latency-performance || true

log "2️⃣ Disk & I/O"
backup /etc/fstab
sed -i 's/defaults/defaults,noatime/' /etc/fstab || true
systemctl enable --now fstrim.timer
for d in /sys/block/nvme*/queue/scheduler; do echo mq-deadline > "$d" 2>/dev/null || true; done
cat <<EOF >/etc/udev/rules.d/60-io-scheduler.rules
ACTION=="add", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="mq-deadline"
EOF
udevadm control --reload-rules && udevadm trigger

log "3️⃣ Boot & Service Optimization"
for svc in bluetooth cups avahi-daemon whoopsie apport; do systemctl disable --now $svc 2>/dev/null || true; done
sed -i 's/#DefaultTimeoutStartSec=.*/DefaultTimeoutStartSec=10s/' /etc/systemd/system.conf
sed -i 's/#DefaultTimeoutStopSec=.*/DefaultTimeoutStopSec=10s/' /etc/systemd/system.conf

log "4️⃣ Network & TCP"
backup /etc/sysctl.conf
cat <<EOF >> /etc/sysctl.conf
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_fin_timeout=15
net.ipv4.tcp_keepalive_time=600
net.ipv4.tcp_window_scaling=1
net.ipv4.tcp_fastopen=3
EOF
sysctl -p
systemctl restart systemd-resolved || true

log "5️⃣ Memory & Swap"
append_unique 'vm.swappiness=10' /etc/sysctl.conf
sysctl -p
apt install -y zram-tools
systemctl enable --now zram-config

log "6️⃣ GPU & Graphics"
apt install -y mesa-utils vulkan-tools
ubuntu-drivers autoinstall || true

log "7️⃣ Security"
apt install -y ufw fail2ban unattended-upgrades
ufw --force enable
ufw default deny incoming
ufw allow ssh

log "8️⃣ Developer Tools"
apt install -y neovim fzf ripgrep fd-find bat exa tmux tree jq
append_unique 'alias cat="batcat"' /etc/zshrc
append_unique 'alias ll="exa -alh --git"' /etc/zshrc

log "9️⃣ Docker Optimization"
mkdir -p /etc/docker
cat <<EOF >/etc/docker/daemon.json
{
  "storage-driver": "overlay2",
  "log-driver": "local",
  "log-opts": {"max-size": "10m", "max-file": "3"}
}
EOF
systemctl daemon-reexec
systemctl restart docker || true

log "🔟 Dev Kernel Parameters"
append_unique 'fs.inotify.max_user_watches=524288' /etc/sysctl.conf
sysctl -p

log "✅ Clean up & Reclaim"
apt autoremove -y && apt autoclean -y
journalctl --vacuum-time=7d || true

log "🎯 Optimization Complete — Reboot Recommended!"
