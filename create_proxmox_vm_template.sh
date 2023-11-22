#!/bin/bash

# This script generates a basic, pre-configured Proxmox VM template, which Packer utilizes as a bootstrap to create a finalized template image.

set -e

# Variables
EDITOR='nano'
SRC_IMG="https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
IMG_NAME="debian-12-genericcloud-amd64.qcow2"
TEMP_NAME="debian12-custom-amd64.qcow2"
TEMPL_NAME="debian12-cloud"
VMID="9000"
MEM="4096"
DISK_SIZE="40G"
DISK_STOR="local"
NET_BRIDGE="vmbr0"
CIUSER="packer" # I set this to my actual desired username
IPCONFIG=gw=192.168.1.1,ip=192.168.1.100/24
PUBKEY=./files/pubkey

# Check if required variables are set
if [[ -z "$SRC_IMG" || -z "$IMG_NAME" || -z "$TEMP_NAME" || -z "$TEMPL_NAME" || -z "$VMID" || -z "$MEM" || -z "$DISK_SIZE" || -z "$DISK_STOR" || -z "$NET_BRIDGE" || -z "$CIUSER" || -z "$IPCONFIG" || -z "$PUBKEY" ]]; then
    echo "Error: One or more required variables are not set."
    exit 1
fi

# Functions
function install_packages() {
    echo "Installing necessary packages..."
    apt update
    apt install -y libguestfs-tools
}

function download_image() {
    local src_img=$1
    local img_name=$2

    if [[ -f $img_name ]]; then
        echo "Image $img_name already exists, skipping download."
    else
        echo "Downloading image from $src_img..."
        wget -O $img_name $src_img
    fi
}

function customize_image() {
    local temp_name=$1

    echo "Customizing image..."
    virt-customize --install qemu-guest-agent,openssh-server,cloud-init --upload ./files/sshd_config_initial:/etc/ssh/ --firstboot-command 'ssh-keygen -A' --timezone America/Denver -a $temp_name
}

function create_vm() {
    local vmid=$1
    local templ_name=$2
    local mem=$3
    local net_bridge=$4
    local temp_name=$5
    local disk_stor=$6
    local ciuser=$7
    local pubkey=$8
    local ipconfig=$9
    local disk_size=${10}

    echo "Creating VM..."
    qm create $vmid --name $templ_name --memory $mem --net0 virtio,bridge=$net_bridge
    qm importdisk $vmid $temp_name $disk_stor
    qm set $vmid --scsihw virtio-scsi-pci --scsi0 $disk_stor:$vmid/vm-$vmid-disk-0.raw,ssd=1
    qm set $vmid --ide2 $disk_stor:cloudinit
    qm set $vmid --boot c --bootdisk scsi0 --agent enabled=1 --localtime true --ostype l26
    qm set $vmid --ciuser $ciuser
    qm set $vmid --sshkey $pubkey
    qm set $vmid --serial0 socket --vga serial0
    qm set $vmid --ipconfig0 $ipconfig
    qm resize $vmid scsi0 $disk_size
}

function convert_to_template() {
    local vmid=$1

    echo "Converting VM to template..."
    qm template $vmid
}

function cleanup() {
    local temp_name=$1

    echo "Cleaning up..."
    rm $temp_name
}

# Main
install_packages
download_image $SRC_IMG $IMG_NAME
cp $IMG_NAME $TEMP_NAME
customize_image $TEMP_NAME
create_vm $VMID $TEMPL_NAME $MEM $NET_BRIDGE $TEMP_NAME $DISK_STOR $CIUSER $PUBKEY $IPCONFIG $DISK_SIZE
convert_to_template $VMID
cleanup $TEMP_NAME

echo "Script completed successfully!"
