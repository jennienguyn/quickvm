#!/bin/bash

clear
echo -e "\e[32m  ___        _      _   __     ____  __ "
echo -e " / _ \\ _   _(_) ___| | _\\ \\   / /  \\/  |"
echo -e "| | | | | | | |/ __| |/ /\\ \\ / /| |\\/| |"
echo -e "| |_| | |_| | | (__|   <  \\ V / | |  | |"
echo -e " \\___\\_\\\\__,_|_|\\___|_|\\_\\  \\_/  |_|  |_|"
echo
echo -e "                 by jennienguyn"
echo -e "\e[0m"

if [[ "$PREFIX" == *"/data/data/com.termux"* ]]; then
    echo "[*] Dang cai dat PulseAudio cho Termux..."
    pkg install pulseaudio -y
    export PULSE_SERVER=127.0.0.1
    pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
    echo "[*] PulseAudio da san sang."
fi

VM_NAME="win2012r2"
DISK_IMG="$VM_NAME.qcow2"

RAM="4096"
CPU="2"
DISK_SIZE="40G"

WIN_ISO="./iso/win2012r2.iso"
VIRTIO_ISO="./iso/virtio-win.iso"

WIN_URL="https://mirror.orfi.net.tr/Windows/Windows-Server-2012-R2-Aug-2018.iso"
VIRTIO_URL="https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.102/virtio-win-0.1.102.iso"

download_iso() {
    mkdir -p iso

    echo "Ban co muon tu dong tai Windows Server 2012 R2 ISO?"
    read -p "(y/N): " ans
    if [[ "$ans" == "y" || "$ans" == "Y" ]]; then
        echo "[*] Dang tai Windows ISO..."
        curl -L "$WIN_URL" -o "$WIN_ISO"
        echo "[*] Da tai xong: $WIN_ISO"
    fi

    echo "Ban co muon tu dong tai VirtIO ISO?"
    read -p "(y/N): " ans2
    if [[ "$ans2" == "y" || "$ans2" == "Y" ]]; then
        echo "[*] Dang tai VirtIO ISO..."
        curl -L "$VIRTIO_URL" -o "$VIRTIO_ISO"
        echo "[*] Da tai xong: $VIRTIO_ISO"
    fi
}

save_config() {
    cat << EOF > ${VM_NAME}.cfg
RAM=$RAM
CPU=$CPU
DISK_SIZE=$DISK_SIZE
ACCEL=$ACCEL
EOF
}

load_config() {
    if [ -f "${VM_NAME}.cfg" ]; then
        source ${VM_NAME}.cfg
    fi
}

create_disk() {
    echo "[*] Tao o dia moi: $DISK_IMG voi dung luong $DISK_SIZE ..."
    qemu-img create -f qcow2 "$DISK_IMG" "$DISK_SIZE"
}

install_vm() {

    download_iso

    echo "=== CAU HINH VM KHI CAI DAT ==="

    read -p "Nhap RAM (MB, mac dinh 4096): " inp_ram
    if [ ! -z "$inp_ram" ]; then RAM="$inp_ram"; fi

    read -p "Nhap so luong CPU (mac dinh 2): " inp_cpu
    if [ ! -z "$inp_cpu" ]; then CPU="$inp_cpu"; fi

    read -p "Nhap dung luong o dia (VD: 40G, mac dinh 40G): " inp_disk
    if [ ! -z "$inp_disk" ]; then DISK_SIZE="$inp_disk"; fi

    echo "Chon bo ao hoa:"
    echo "1) KVM (neu ho tro)"
    echo "2) TCG (software emulation)"
    read -p "Lua chon (1/2, mac dinh 1): " accel_choice
    case "$accel_choice" in
        2) ACCEL="tcg" ;;
        *) ACCEL="kvm" ;;
    esac

    echo "==> RAM: $RAM MB"
    echo "==> CPU: $CPU"
    echo "==> DISK: $DISK_SIZE"
    echo "==> Acceleration: $ACCEL"
    echo

    save_config

    if [ ! -f "$DISK_IMG" ]; then
        create_disk
    fi

    echo "[*] Khoi chay VM (che do CAI DAT)..."

    qemu-system-x86_64 \
        -accel $ACCEL \
        -name $VM_NAME \
        -machine type=q35 \
        -cpu host \
        -smp $CPU \
        -m $RAM \
        -rtc clock=host,base=localtime \
        -boot order=d \
        -device virtio-scsi-pci,id=scsi0 \
        -drive file="$DISK_IMG",if=none,id=drive0,format=qcow2 \
        -device scsi-hd,drive=drive0 \
        -drive file="$WIN_ISO",media=cdrom \
        -drive file="$VIRTIO_ISO",media=cdrom \
        -device virtio-net-pci,netdev=net0 \
        -netdev user,id=net0 \
        -vga qxl \
        -spice port=5930,disable-ticketing=on \
        -device virtio-serial \
        -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \
        -chardev spicevmc,id=spicechannel0,name=vdagent \
        -monitor stdio
}

start_vm() {

    if [ ! -f "$DISK_IMG" ]; then
        echo "[!] Khong tim thay o dia VM. Hay cai dat truoc."
        exit 1
    fi

    load_config

    echo "[*] Khoi dong VM voi cau hinh:"
    echo "    RAM  = $RAM"
    echo "    CPU  = $CPU"
    echo "    DISK = $DISK_IMG"
    echo "    Accel = $ACCEL"
    echo

    qemu-system-x86_64 \
        -accel $ACCEL \
        -name $VM_NAME \
        -machine type=q35,accel=$ACCEL \
        -cpu host \
        -smp $CPU \
        -m $RAM \
        -rtc clock=host,base=localtime \
        -boot order=c \
        -device virtio-scsi-pci,id=scsi0 \
        -drive file="$DISK_IMG",if=none,id=drive0,format=qcow2 \
        -device scsi-hd,drive=drive0 \
        -device virtio-net-pci,netdev=net0 \
        -netdev user,id=net0 \
        -vga qxl \
        -spice port=5930,disable-ticketing=on \
        -device virtio-serial \
        -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \
        -chardev spicevmc,id=spicechannel0,name=vdagent \
        -monitor stdio
}

reset_vm() {
    echo "=============================================="
    echo "CANH BAO: Reset se XOA TOAN BO du lieu VM!"
    echo "File bi xoa: $DISK_IMG + file config .cfg"
    echo "=============================================="
    read -p "Nhap YES de xac nhan: " conf

    if [ "$conf" == "YES" ]; then
        rm -f "$DISK_IMG" "${VM_NAME}.cfg"
        echo "[*] Da reset VM. San sang cai lai."
    else
        echo "[!] Huy reset."
    fi
}

echo "=============================="
echo "  QUAN LY VM Windows 2012R2"
echo "=============================="
echo "1) Cai Windows (Install)"
echo "2) Chay VM (Start)"
echo "3) Reset VM (Xoa du lieu)"
echo "0) Thoat"
echo "=============================="
read -p "Chon: " choice

case $choice in
    1) install_vm ;;
    2) start_vm ;;
    3) reset_vm ;;
    0) exit 0 ;;
    *) echo "Lua chon khong hop le." ;;
esac
