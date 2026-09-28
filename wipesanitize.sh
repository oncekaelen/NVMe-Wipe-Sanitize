#!/bin/bash

# Install nvme-cli if it's missing
if ! command -v nvme &> /dev/null; then
    echo "nvme-cli not found. Installing..."
    if sudo apt update &> /dev/null && sudo apt install -y nvme-cli &> /dev/null; then
        echo "nvme-cli installed."
    else
        echo "Failed to install nvme-cli. Exiting."
        exit 1
    fi
fi

# Secure erase every NVMe drive
drives=$(sudo nvme list 2> /dev/null | awk '/^\/dev\/nvme/ {print $1}')

if [ -z "$drives" ]; then
    echo "No NVMe drives found."
else
    for drive in $drives; do
        echo "Formatting $drive..."
        if sudo nvme format "$drive" -s 1 --force &> /dev/null; then
            echo "$drive formatted."
        else
            echo "Failed to format $drive."
        fi
    done
fi

# Reload the NVMe driver
echo "Reloading NVMe driver..."
if sudo rmmod nvme &> /dev/null && sudo modprobe nvme &> /dev/null; then
    echo "NVMe driver reloaded."
else
    echo "Failed to reload NVMe driver."
fi
sleep 2

# Delete all EFI boot entries
entries=$(sudo efibootmgr 2> /dev/null | sed -n 's/^Boot\([0-9A-Fa-f]\{4\}\).*/\1/p')

if [ -z "$entries" ]; then
    echo "No EFI boot entries found."
else
    for entry in $entries; do
        echo "Deleting boot entry $entry..."
        if sudo efibootmgr -b "$entry" -B &> /dev/null; then
            echo "Boot entry $entry deleted."
        else
            echo "Failed to delete boot entry $entry."
        fi
    done
fi

sleep 5

# Power off
echo "Shutting down..."
sudo systemctl poweroff -i &> /dev/null
