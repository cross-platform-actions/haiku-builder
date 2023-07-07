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

variable "accelerator" {
  default = "tcg"
  type = string
  description = "The accelerator type to use when running the VM"
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
  accelerator = var.accelerator
  qemu_binary = "qemu-system-${var.architecture.qemu}"
  cpu_model = var.cpu_type
  efi_firmware_code = "/opt/homebrew/share/qemu/edk2-x86_64-code.fd"
  efi_firmware_vars = "/opt/homebrew/share/qemu/edk2-i386-vars.fd"

  boot_wait = "1m"

  boot_steps = [
    ["a<enter><wait5>", "Installation messages in English"]
  ]

  ssh_username = "root"
  ssh_password = var.root_password
  ssh_timeout = "10000s"

  qemuargs = [
    ["-boot", "strict=off"],
    ["-monitor", "none"],

    ["-device", "virtio-vga"],
    ["-usb"],
    ["-device", "usb-tablet,bus=usb-bus.0"],
    ["-device", "usb-mouse,bus=usb-bus.0"],
    ["-device", "usb-kbd,bus=usb-bus.0"],
    ["-device", "nec-usb-xhci,id=usb-controller-0"]
  ]

  iso_checksum = var.checksum
  iso_urls = [
    "http://mirror.rit.edu/haiku/r1beta4/haiku-r1beta4-x86_64-anyboot.iso",
    "https://ftp.osuosl.org/pub/haiku/r1beta4/haiku-r1beta4-x86_64-anyboot.iso",
    "https://s3.us-east-1.wasabisys.com/haiku-release/r1beta4/haiku-r1beta4-x86_64-anyboot.iso",
    "https://cloudflare-ipfs.com/ipns/hpkg.haiku-os.org/release/r1beta4/haiku-r1beta4-x86_64-anyboot.iso",
    "https://mirror.aarnet.edu.au/pub/haiku/r1beta4/haiku-r1beta4-x86_64-anyboot.iso",
  ]

  http_directory = "."
  output_directory = "output"
  shutdown_command = "/sbin/poweroff"
  vm_name = local.vm_name
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
    environment_vars = [
      "SECONDARY_USER=${var.secondary_user_username}"
    ]
  }
}
