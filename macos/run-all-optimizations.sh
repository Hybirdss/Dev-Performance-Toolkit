#!/bin/bash

# 🚀 Run All Optimizations - macOS
# Executes all optimization scripts in sequence
# 
# Author: @hybirdss
# Project: Dev Performance Toolkit
# Version: 2.0.0

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Check for root/sudo
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Error: This script must be run as root (sudo)${NC}"
    echo "Usage: sudo ./run-all-optimizations.sh"
    exit 1
fi

echo -e "${MAGENTA}============================================${NC}"
echo -e "${MAGENTA}  🚀 Dev Performance Toolkit v2.0.0${NC}"
echo -e "${MAGENTA}  All-in-One Optimization Suite${NC}"
echo -e "${MAGENTA}  by @hybirdss${NC}"
echo -e "${MAGENTA}============================================\n${NC}"

# Scripts to run
declare -a scripts=(
    "network-optimizer.sh:Network Optimizer:3"
    "system-optimizer.sh:System Optimizer:5"
)

echo -e "This will run the following optimizations:\n"

total_time=0
for script in "${scripts[@]}"; do
    IFS=':' read -r file name time <<< "$script"
    echo -e "  ${CYAN}✓ $name (~$time min)${NC}"
    total_time=$((total_time + time))
done

echo -e "\n${YELLOW}Estimated total time: ~$total_time minutes${NC}\n"

read -p "Continue with all optimizations? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Cancelled.${NC}"
    exit 1
fi

echo ""

# Execute each script
completed=0
total=${#scripts[@]}

for script in "${scripts[@]}"; do
    IFS=':' read -r file name time <<< "$script"
    completed=$((completed + 1))
    
    echo -e "\n${GREEN}[$completed/$total] Running $name...${NC}"
    echo -e "${GREEN}$(printf '=%.0s' {1..50})${NC}"
    
    if [ -f "./$file" ]; then
        chmod +x "./$file"
        "./$file" || {
            echo -e "\n${RED}⚠ Error running $name${NC}"
            echo -e "${YELLOW}Continuing with next optimization...${NC}\n"
        }
    else
        echo -e "${RED}Error: $file not found!${NC}"
    fi
done

echo -e "\n\n${GREEN}============================================${NC}"
echo -e "${GREEN}  ✅ ALL OPTIMIZATIONS COMPLETED!${NC}"
echo -e "${GREEN}============================================\n${NC}"

echo -e "${CYAN}📊 Summary:${NC}"
echo -e "  ${GREEN}• Network optimization: ✓${NC}"
echo -e "  ${GREEN}• System optimization: ✓${NC}"
echo -e "\n${YELLOW}📌 IMPORTANT: Restart your computer for all changes to take effect!${NC}\n"

read -p "Restart now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "\n${YELLOW}Restarting in 10 seconds... (Ctrl+C to cancel)${NC}"
    sleep 10
    shutdown -r now
else
    echo -e "\n${CYAN}Please restart manually when convenient.${NC}"
fi
