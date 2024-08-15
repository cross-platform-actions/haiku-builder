#!/bin/sh

set -exu

install_extra_packages() {
  echo "yes\n" | pkgman add  "https://eu.hpkg.haiku-os.org/haiku/master/$(getarch)/current"
  echo "yes\n" | pkgman add  "https://eu.hpkg.haiku-os.org/haikuports/master/$(getarch)/current"

  pkgman refresh
  pkgman install rsync -y
}

install_extra_packages
