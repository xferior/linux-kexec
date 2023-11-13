#!/bin/sh
# Name: linux-kexec-boot.sh
# Date: November 12, 2023
# Description: Switch between installed Linux kernels using kexec
# Useage: linux-kexec-boot.sh (follow prompts)
#         linux-kexec-boot.sh --latest (for use with patch automation)

# Function to find the initram image for a kernel
find_initrd() {
  KERNEL_VERSION=$(basename "$1" | sed -e 's/vmlinuz-//')

  # Check common names for initram
  for PREFIX in initrd initrd.img initramfs; do
    for SUFFIX in "" ".img" "-generic" "-current" "-default"; do
      INITRD_PATH="/boot/${PREFIX}-${KERNEL_VERSION}${SUFFIX}"
      if [ -f "$INITRD_PATH" ]; then
        echo "$INITRD_PATH"
        return
      fi
    done
  done
  echo ""
}

# Function to load and execute selected kernel
kexec_kernel() {
  KERNEL=$1
  INITRD=$(find_initrd "$KERNEL")

  if [ -z "$INITRD" ]; then
    echo "No matching initram file found for kernel: $KERNEL" >&2
    exit 1
  fi

  # Execute kexec to load the kernel and initram. Remove /boot from name
  echo "Loading kernel: $(echo "$KERNEL" | sed -e 's|/boot/||')"
  echo "Loading initrd: $(echo "$INITRD" | sed -e 's|/boot/||')"
  kexec -l "$KERNEL" --initrd="$INITRD" --reuse-cmdline

  # Execute kexec to boot into selected kernel
  echo "Booting to selected kernel..."
  exit 0
  kexec -e
}

# Check for --latest argument 
if [ "$1" = "--latest" ]; then
  # Find the latest kernel based on version sort
  LATEST_KERNEL=$(ls /boot/vmlinuz-* | grep -v 'rescue' | sort -V | tail -n 1)
  
  if [ -z "$LATEST_KERNEL" ]; then
    printf "No kernels found in /boot.\n" >&2
    exit 1
  fi

  printf "The latest kernel found is: %s\n" "$(basename "$LATEST_KERNEL" | sed -e 's/vmlinuz-//')"
  printf "Booting to latest kernel...\n"
  kexec_kernel "$LATEST_KERNEL"
  exit 0
fi

# Check if kexec-tools are installed
if ! command -v kexec >/dev/null 2>&1; then
  printf "kexec is not installed. " >&2
  if command -v apt-get >/dev/null 2>&1; then
    printf "Try installing it using: sudo apt-get install kexec-tools\n" >&2
  elif command -v yum >/dev/null 2>&1; then
    printf "Try installing it using: sudo yum install kexec-tools\n" >&2
  elif command -v dnf >/dev/null 2>&1; then
    printf "Try installing it using: sudo dnf install kexec-tools\n" >&2
  elif command -v pacman >/dev/null 2>&1; then
    printf "Try installing it using: sudo pacman -S kexec-tools\n" >&2
  else
    printf "Please install kexec-tools using your package manager.\n" >&2
  fi
  exit 1
fi

# Check that script is being run as root
if [ "$(id -u)" -ne 0 ]; then
  printf "This script must be run as root\n" >&2
  exit 1
fi

# List the vmlinuz files in /boot, excluding rescue entries
KERNELS=$(ls /boot/vmlinuz-* 2>/dev/null | grep -v 'rescue' | sort -V)

# Count number of kernels found
NUM_KERNELS=$(echo "$KERNELS" | wc -l | tr -d '[:space:]')

# If no kernels are found, exit script
if [ "$NUM_KERNELS" -eq 0 ]; then
  printf "No vmlinuz kernels found in /boot.\n" >&2
  exit 1
fi

# Show running kernel
CURRENT_KERNEL=$(uname -r)
printf "The running kernel is: %s\n" "$CURRENT_KERNEL"

# If only one kernel is installed, ask user to reboot into running kernel
if [ "$NUM_KERNELS" -eq 1 ]; then
  printf "Only one kernel found: %s\n" "$(basename "$KERNELS" | sed -e 's/vmlinuz-//')"
  printf "Would you like to kexec into this kernel? (y/n) "
  read ANSWER
  case "$ANSWER" in
    [yY]|[yY][eE][sS])
      kexec_kernel "$KERNELS"
      ;;
    *)
      printf "Exiting\n"
      exit 0
      ;;
  esac
else
  # If more than one kernel is found, prompt for user choice
  printf "Select the kernel to kexec boot into:\n"
  INDEX=1
  for KERNEL in $KERNELS; do
    printf "%d) %s\n" "$INDEX" "$(basename "$KERNEL" | sed -e 's/vmlinuz-//')"
    INDEX=$((INDEX + 1))
  done

  # Prompt for user input
  printf "Enter kernel line number: "
  read CHOICE

  # Check if the choice is non-empty, numerical, and within the valid range
  case "$CHOICE" in
    ''|*[!0-9]*)
      printf "Invalid selection. Please enter a numerical value.\n"
      CHOICE=""
      ;;
    *)
      if [ "$CHOICE" -lt 1 ] || [ "$CHOICE" -gt "$NUM_KERNELS" ]; then
        printf "Invalid selection. Please enter a number from 1 to %d.\n" "$NUM_KERNELS"
        CHOICE=""
      else
        # Get the selected kernel
        SELECTED_KERNEL=$(echo "$KERNELS" | sed -n "${CHOICE}p")
        printf "You have selected: %s\n" "$(basename "$SELECTED_KERNEL" | sed -e 's/vmlinuz-//')"
        # Run kexec
        kexec_kernel "$SELECTED_KERNEL"
      fi
      ;;
  esac
fi
