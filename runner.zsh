#!/bin/zsh

set -e # Exit immediately if any command fails

# =========================
# CONFIGURATION
# =========================

HYPERLOADER_ASM="bootloader.asm"
HYPERLOADER_BIN="hyperloader.bin"
FLOPPY_IMG="hyperloader.img"
ISO_FILE="hyperloader.iso"
ISO_DIR="./iso_build_temp"

CLEANUP=true
RUN_QEMU=false

# =========================
# ARGUMENT PARSING
# =========================

for arg in "$@"; do
  case "$arg" in
  --no-cleanup)
    CLEANUP=false
    ;;
  --run)
    RUN_QEMU=true
    ;;
  --asm=*)
    HYPERLOADER_ASM="${arg#--asm=}"
    ;;
  esac
done

# =========================
# CLEANUP HANDLER
# =========================

function cleanup {
  if $CLEANUP; then
    echo "[+] Cleaning up temporary files..."
    rm -rf "$HYPERLOADER_BIN" "$FLOPPY_IMG" "$ISO_DIR"
  else
    echo "[*] Skipping cleanup, temp dir preserved at: $ISO_DIR"
  fi
}
trap cleanup EXIT

# =========================
# ASSEMBLE BOOTLOADER
# =========================

echo "[+] Assembling hyperloader..."
nasm -f bin -o "$HYPERLOADER_BIN" "$HYPERLOADER_ASM" || {
  echo "[-] Failed to assemble hyperloader"
  exit 1
}

# =========================
# CREATE FLOPPY IMAGE
# =========================

echo "[+] Creating 1.44MB floppy image..."
dd if=/dev/zero of="$FLOPPY_IMG" bs=1024 count=1440 status=none
dd if="$HYPERLOADER_BIN" of="$FLOPPY_IMG" seek=0 count=1 conv=notrunc status=none

# =========================
# PREP ISO FOLDER IN CWD
# =========================

echo "[+] Preparing ISO directory..."
mkdir -p "$ISO_DIR"
cp "$FLOPPY_IMG" "$ISO_DIR/hyperloader.img"

# =========================
# CREATE ISO FILE
# =========================

echo "[+] Creating ISO image..."
genisoimage -quiet -V 'HYPERLOADER' -input-charset iso8859-1 \
  -o "$ISO_FILE" -b hyperloader.img -hide hyperloader.img "$ISO_DIR" || {
  echo "[-] ISO creation failed"
  exit 1
}

# =========================
# QEMU RUN OPTION
# =========================

if $RUN_QEMU; then
  echo "[+] Running hyperloader in QEMU..."
  qemu-system-i386 -cdrom "$ISO_FILE"
else
  echo "[✔] Hyperloader ISO created successfully: $ISO_FILE"
fi
