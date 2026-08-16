#!/bin/sh

set -exu

# Downloading from the Haiku package servers intermittently fails with an I/O
# error part way through a transfer, which fails the whole build.
retry() {
  attempt=1

  while true; do
    "$@" && return 0
    [ "$attempt" -ge 5 ] && return 1

    delay=$((attempt * 10))
    echo "'$*' failed, retrying in ${delay}s" >&2
    sleep "$delay"
    attempt=$((attempt + 1))
  done
}

install_extra_packages() {
  retry pkgman refresh
  retry pkgman install bash curl rsync -y
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
