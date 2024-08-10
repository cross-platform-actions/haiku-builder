variable "os_version" {
  type = string
  description = "The version of the operating system to download and install"
}

variable "architecture" {
  type = object({
    name = string
    image = string
    qemu = string
  })
  description = "The type of CPU to use when building"
}

variable "machine_type" {
  default = "q35"
  type = string
  description = "The type of machine to use when building"
}

variable "cpu_type" {
  default = "qemu64"
  type = string
  description = "The type of CPU to use when building"
}

variable "memory" {
  default = 4096
  type = number
  description = "The amount of memory to use when building the VM in megabytes"
}

variable "cpus" {
  default = 2
  type = number
  description = "The number of cpus to use when building the VM"
}

variable "disk_size" {
  default = "12G"
  type = string
  description = "The size in bytes of the hard disk of the VM"
}

variable "checksum" {
  type = string
  description = "The checksum for the virtual hard drive file"
}

variable "root_password" {
  default = "vagrant"
  type = string
  description = "The password for the root user"
}

variable "secondary_user_password" {
  default = "vagrant"
  type = string
  description = "The password for the `secondary_user_username` user"
}

variable "secondary_user_username" {
  default = "vagrant"
  type = string
  description = "The name for the secondary user"
}

variable "headless" {
  default = false
  description = "When this value is set to `true`, the machine will start without a console"
}

variable "use_default_display" {
  default = true
  type = bool
  description = "If true, do not pass a -display option to qemu, allowing it to choose the default"
}

variable "display" {
  default = "cocoa"
  description = "What QEMU -display option to use"
}

variable "firmware" {
  type = string
  description = "The firmware file to be used by QEMU"
}

locals {
  iso_target_extension = "iso"
  iso_target_path = "packer_cache"
  iso_full_target_path = "${local.iso_target_path}/${sha1(var.checksum)}.${local.iso_target_extension}"

  vm_name = "haiku-${var.os_version}-${var.architecture.name}.qcow2"
  iso_path = "r1beta4/haiku-${var.os_version}-${var.architecture.image}-anyboot.iso"
}

source "qemu" "qemu" {
  machine_type = var.machine_type
  cpus = var.cpus
  memory = var.memory
  net_device = "virtio-net"

  disk_compression = true
  disk_interface = "virtio"
  disk_size = var.disk_size
  format = "qcow2"

  headless = var.headless
  use_default_display = var.use_default_display
  display = var.display
  accelerator = "none"
  qemu_binary = "qemu-system-${var.architecture.qemu}"
  cpu_model = var.cpu_type

  ssh_username = "user"
  ssh_password = var.root_password
  ssh_timeout = "10000s"

  qemuargs = [
    ["-boot", "strict=off"],
    ["-monitor", "none"],

    ["-accel", "kvm"],
    ["-accel", "hvf"],
    ["-accel", "tcg"],

    ["-device", "virtio-vga"],
    ["-usb"],
    ["-device", "usb-tablet,bus=usb-bus.0"],
    ["-device", "usb-mouse,bus=usb-bus.0"],
    ["-device", "usb-kbd,bus=usb-bus.0"],
    ["-device", "nec-usb-xhci,id=usb-controller-0"],

    ["-device", "virtio-blk,drive=drive0,bootindex=0"],
    ["-device", "ide-cd,drive=drive1,bootindex=1"],
    ["-drive", "if=none,file={{ .OutputDir }}/{{ .Name }},id=drive0,cache=writeback,discard=ignore,format=qcow2"],
    ["-drive", "if=none,file=${local.iso_full_target_path},id=drive1,media=disk,format=raw,readonly=on"]
  ]

  iso_checksum = var.checksum
  iso_target_extension = local.iso_target_extension
  iso_target_path = local.iso_target_path
  iso_urls = [
    "http://mirror.rit.edu/haiku/r1beta4/haiku-r1beta4-${var.architecture.image}-anyboot.iso",
    "https://ftp.osuosl.org/pub/haiku/r1beta4/haiku-r1beta4-${var.architecture.image}-anyboot.iso",
    "https://s3.us-east-1.wasabisys.com/haiku-release/r1beta4/haiku-r1beta4-${var.architecture.image}-anyboot.iso",
    "https://cloudflare-ipfs.com/ipns/hpkg.haiku-os.org/release/r1beta4/haiku-r1beta4-${var.architecture.image}-anyboot.iso",
    "https://mirror.aarnet.edu.au/pub/haiku/r1beta4/haiku-r1beta4-${var.architecture.image}-anyboot.iso",
  ]

  http_directory = "."
  output_directory = "output"
  shutdown_command = "shutdown -q"
  vm_name = local.vm_name

  boot_wait = "40s"

  boot_steps = [
    // Installer
    ["<tab><wait>", "Keymap"],
    ["<tab><wait>", "Select 'Install Haiku'"],
    ["<spacebar><wait>", "Press 'Install Haiku'"],

    ["<enter><wait>", "Continue"],

    ["<enter><wait>", "No parations have been found ..."],

    ["<tab><wait>", "Install from"],
    ["<tab><wait>", "Onto"],
    ["<tab><wait>", "Show optional packages"],
    ["<tab><wait>", "Select 'Set up partions'"],
    ["<spacebar><wait>", "Press 'Set up partions'"],

    // DriveSetup
    ["<down><wait>", "DVD 1 - Haiku"],
    ["<down><wait>", "DVD 1 - haiku eps"],
    ["<down><wait>", "DVD 2"],
    ["<down><wait>", "/dev/disk/virtual/virtio_block/0/raw"],
    ["<leftAltOn><esc><leftAltOff><wait>", "open main menu"],
    ["<right><wait>", "Partition"],
    ["<down><wait>", "Select 'Format'"],
    ["<right><wait>", "Open 'Format'"],
    ["<spacebar><wait>", "Press 'Be File System'"],

    ["<tab><wait>", "Select Continue"],
    ["<spacebar><wait>", "Press Continue"],

    ["<enter><wait>", "Format"],

    // Are you sure you want to write the changes back to disk now?
    ["<tab><wait>", "Select Write changes"],
    ["<spacebar><wait>", "Press Write changes"],

    // The partion "Haiku" has been successfully formatted.
    ["<enter><wait>", "OK"],

    // DriveSetup
    ["<leftAltOn>w<leftAltOff><wait>", "Close"],

    // Installer
    ["<leftShiftOn><tab><leftShiftOff><wait>", "Show optional packages"],
    ["<leftShiftOn><tab><leftShiftOff><wait>", "Select 'Onto'"],
    ["<down><wait>", "Open 'Onto'"],
    ["<up><down><wait>", "Select '/dev/disk/virtual/virtio_block/0/raw'"],
    ["<enter><wait>", "Press '/dev/disk/virtual/virtio_block/0/raw'"],
    ["<enter><wait1m>", "Begin"],
    ["<enter>", "Restart"],
    ["<wait1m>", "Wait for restart"],

    // Haiku. System is now installed and has rebooted. Need to set password.
    ["haiku<enter>", "Haiku"],
    ["system<enter><wait5s>", "Change to 'system' directory"],
    ["apps<enter><wait5s>", "Change to 'apps' directory"],
    ["Terminal<enter><wait5s>", "Start 'Terminal', application"],
    ["passwd<enter><wait>", "Execute 'passwd' command"],
    ["${var.root_password}<enter><wait>", "Set password"],
    ["${var.root_password}<enter><wait>", "Confirm set password"],
    [
      "echo 'PermitRootLogin yes' >> /system/settings/ssh/sshd_config<enter><wait>",
      "Enable SSH login for root user"
    ],
    ["exit<enter><wait>", "Exit Terminal"],

    // Restart SSH daemon
    ["<leftAltOn>w<leftAltOff><wait>", "Close 'apps' window"],
    ["preferences<enter><wait5s>", "Change to 'preferences' directory"],
    ["network<enter><wait5s>", "Open Network preferences"],
    ["<tab><wait>", "Select left side list"],
    ["<down>", "IPv4"],
    ["<down>", "IPv6"],
    ["<down>", "Services"],
    ["<down>", "DNS Settings"],
    ["<down>", "FTP server"],
    ["<down>", "Hostname settings"],
    ["<down><wait>", "SSH server"],
    ["<tab><wait>", "Move focus to 'Disable' button"],
    ["<spacebar><wait5s>", "Click Disable"],
    ["<spacebar>", "Click Enable"]
  ]
}

packer {
  required_plugins {
    qemu = {
      version = "~> 1.0.9"
      source = "github.com/hashicorp/qemu"
    }
  }
}

build {
  sources = ["qemu.qemu"]

  provisioner "shell" {
    script = "resources/provision.sh"
  }

  provisioner "shell" {
    script = "resources/custom.sh"
  }

  provisioner "shell" {
    script = "resources/cleanup.sh"
  }
}
