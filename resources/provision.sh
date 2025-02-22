#!/bin/sh

set -exu

install_extra_packages() {
  pkgman refresh
  pkgman install bash curl rsync -y
}

# install_extra_packages

echo "foo" > /tmp/bar.txt
