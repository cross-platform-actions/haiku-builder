#!/bin/sh

set -exu

cleanup() {
  find /var/log -type f | xargs truncate -s 0
  rm -rf /tmp/*
}

cleanup
