#!/bin/sh
set -eu

KERNEL_DIR=$(pwd)
OWNER="ThRE-Team"
REPO="Next-v3"
BRANC="main"

initialize_variables() {
    if test -d "$KERNEL_DIR/common/drivers"; then
         DRIVER_DIR="$KERNEL_DIR/common/drivers"
    elif test -d "$KERNEL_DIR/drivers"; then
         DRIVER_DIR="$KERNEL_DIR/drivers"
    else
         echo '[ERROR] "drivers/" directory not found.'
         exit 127
    fi
    DRIVER_MAKEFILE=$DRIVER_DIR/Makefile
    DRIVER_KCONFIG=$DRIVER_DIR/Kconfig
}

setup_kernelsu() {
    echo "[+] Setting up KernelSU-Next..."
    test -d "$KERNEL_DIR/KernelSU-Next" || git clone "https://github.com/$OWNER/$REPO -b $BRANC KernelSU-Next --depth=1" && echo "[+] Repository cloned."
    cd "$KERNEL_DIR/KernelSU-Next"
    git stash && echo "[-] Stashed current changes."
    git pull && echo "[+] Repository updated."
    cd "$DRIVER_DIR"
    ln -sf "$(realpath --relative-to="$DRIVER_DIR" "$KERNEL_DIR/KernelSU-Next/kernel")" "kernelsu" && echo "[+] Symlink created."
    grep -q "kernelsu" "$DRIVER_MAKEFILE" || printf "\nobj-\$(CONFIG_KSU) += kernelsu/\n" >> "$DRIVER_MAKEFILE" && echo "[+] Modified Makefile."
    grep -q "source \"drivers/kernelsu/Kconfig\"" "$DRIVER_KCONFIG" || sed -i "/endmenu/i\source \"drivers/kernelsu/Kconfig\"" "$DRIVER_KCONFIG" && echo "[+] Modified Kconfig."
    echo '[+] Done.'
}

initialize_variables
setup_kernelsu

# Enjoy Your Life...