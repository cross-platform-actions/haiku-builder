#!/bin/sh

set -exu

install_extra_packages() {
  # pkgman refresh
  pkgman install rsync -y
}

install_extra_packages
