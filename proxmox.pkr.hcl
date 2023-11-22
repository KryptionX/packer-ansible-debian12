variable "proxmox_url" {}
variable "username" {}
variable "token" {}
variable "node" {}
variable "clone_vm_id" {}
variable "vm_id" {}
variable "ssh_username" {}
variable "ssh_password" {}
variable "template_name" {}
variable "ciuser" {}
variable "cipassword" {}
variable "ipconfig" {}
variable "disk_stor" {}

packer { 
  required_plugins {
    proxmox = {
      version = "~> 1"
      source  = "github.com/hashicorp/proxmox"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
  }
}

source "proxmox-clone" "debian" {
  node          = var.node
  proxmox_url   = "https://${var.proxmox_url}:8006/api2/json"
  token         = var.token
  username      = var.username
  vm_id         = var.vm_id
  clone_vm_id       = var.clone_vm_id
  cores             = 4
  cpu_type          = "host"
  full_clone        = false
  insecure_skip_tls_verify = true
  memory            = 4096
  network_adapters {
    bridge          = "vmbr0"
    model           = "virtio"
  }
  os                = "l26"
  scsi_controller   = "virtio-scsi-pci"
  ssh_username      = var.ssh_username
  template_name     = var.template_name
  vm_name           = "Debian12-Template"
}

build {
  sources = ["source.proxmox-clone.debian"]
  provisioner "ansible" {
    playbook_file = "./playbook.yml"
    extra_arguments = [ "--extra-vars", "username=${var.ciuser}", "--scp-extra-args", "'-O'" ]
  }
  post-processor "shell-local" {
    environment_vars = ["PROVISIONERTEST=ProvisionerTest2"]
    inline = [
      "echo hello", "echo $PROVISIONERTEST",
      "qm set ${var.vm_id} --scsihw virtio-scsi-pci",
      "qm set ${var.vm_id} --boot c --bootdisk scsi0",
      "qm set ${var.vm_id} --ciuser ${var.ciuser}",
      "qm set ${var.vm_id} --cipassword ${var.cipassword}",
      "qm set ${var.vm_id} --vga std",
      "qm set ${var.vm_id} --ipconfig0 ${var.ipconfig}"
    ]
  }
}
