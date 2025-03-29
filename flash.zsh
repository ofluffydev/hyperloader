#!/bin/zsh

# =========================
# CONFIGURATION
# =========================

IMG="hyperloader.img"

# =========================
# CHECK FOR IMAGE FILE
# =========================

if [[ ! -f "$IMG" ]]; then
  echo "[-] '$IMG' not found."
  echo "[!] Please build the image first using your build script."
  exit 1
fi

# =========================
# LIST USB DEVICES
# =========================

echo "[+] Available block devices:"
lsblk -d -o NAME,SIZE,MODEL | grep -vE "^loop"

echo
echo "Enter the device name of your USB (e.g., sdb, sdc):"
read usbdev

DEVICE_PATH="/dev/$usbdev"

# =========================
# SAFETY CHECK
# =========================

if [[ ! -b "$DEVICE_PATH" ]]; then
  echo "[-] '$DEVICE_PATH' is not a valid block device."
  exit 1
fi

echo "[!] WARNING: This will erase all data on $DEVICE_PATH."
echo "Are you absolutely sure you want to flash '$IMG' to $DEVICE_PATH? (yes/no)"
read confirm

if [[ "$confirm" != "yes" ]]; then
  echo "[-] Aborted by user."
  exit 1
fi

# =========================
# WRITE IMAGE TO USB
# =========================

echo "[+] Flashing $IMG to $DEVICE_PATH..."
sudo dd if="$IMG" of="$DEVICE_PATH" bs=512 status=progress conv=notrunc

sync
echo "[✔] Done. You can now boot from the USB device."
