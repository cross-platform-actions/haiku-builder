#!/bin/sh

set -exu

install_extra_packages() {
  pkgman refresh
  pkgman install bash curl rsync -y
}

add_sudo_shim() {
  curl "$PACKER_HTTP_ADDR/resources/sudo" -o /boot/system/non-packaged/bin/sudo
  chmod +x /boot/system/non-packaged/bin/sudo
}

remove_welcome_banner() {
  sed -i '/Welcome to the Haiku shell/d' /boot/system/settings/etc/profile
}

set_hostname() {
  echo 'runnervmg1sw1.local' > /system/settings/network/hostname
}

install_extra_packages
add_sudo_shim
remove_welcome_banner
set_hostname
