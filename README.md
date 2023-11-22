# Debian 12 based Proxmox VM template using Packer and Ansible

This repository contains scripts and configuration files for creating a pre-configured Proxmox VM template using Packer and Ansible. The VM template is based on Debian 12 (Bookworm) and includes a variety of tools and configurations, such as Docker, Fish shell, and Starship prompt.

## Prerequisites (built using)

- Proxmox Virtual Environment (8.0.9)
- Packer (1.9.4)
- Ansible core (2.15.6)

## Documentation

- [HashiCorp - Packer - Proxmox Clone Builder](https://developer.hashicorp.com/packer/integrations/hashicorp/proxmox/latest/components/builder/clone)
- [HashiCorp - Packer - Ansible Provisioner](https://developer.hashicorp.com/packer/integrations/hashicorp/ansible/latest/components/provisioner/ansible)

## Usage
*I ran this on the same Proxmox host where the image was being created. It may or may not work from other remote proxmox nodes.*

1. Clone this repository to your Proxmox host machine. 

2. Navigate to the root directory of the project.

3. Customize the variables in the `prox.pkrvars.hcl.example` file according to your Proxmox environment and rename it to `prox.pkrvars.hcl`.

4. Run the `create_proxmox_vm_template.sh` script to generate a basic, pre-configured Proxmox VM template, which Packer will utilize as a bootstrap to create a finalized template image in step 5. This script downloads a Debian 12 image, customizes it, creates a VM, and converts it to a template.

```
chmod +x create_proxmox_vm_template.sh
./create_proxmox_vm_template.sh
```

5. Run Packer to create the final VM template. Packer uses the `proxmox.pkr.hcl` configuration file and the `playbook.yml` Ansible playbook for provisioning.

```
packer build -var-file=prox.pkrvars.hcl proxmox.pkr.hcl
```

6. After the build process is complete, you will have a new VM template in your Proxmox environment.


## Additional Information

#### The `playbook.yml` Ansible playbook performs a variety of tasks, including:

- Installing necessary packages
- Setting up Docker
- Creating a new user with sudo privileges
- Configuring Fish shell with Starship prompt
- Setting up SSH for the new user
- Cleaning up the system

#### The `cleanup.sh` script is used to clean up the system before the image is converted to a template. It removes unnecessary files and packages, clears logs, and more.

#### The `motd.txt` file contains ASCII art that is displayed when logging into the system.

#### The `fish_greeting.fish` file is used to display the message of the day (MOTD) when opening a new Fish shell.

#### The `config.fish.j2` file is a Jinja2 template for the Fish shell configuration file. It sets up various aliases and other configurations.
