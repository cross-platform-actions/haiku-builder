checksum = "sha256:f3b498dfd506c546cb7a3f04b869a6d63cd2e6b9e84612fdb47c15a3952adeae"

# R1/beta6 has not been released yet, so the ISO is not available on the
# release mirrors. Build from the official test build in the meantime. Once the
# release is out, remove `iso_urls` and replace the checksum above with the
# checksum of the released ISO.
iso_urls = [
  "https://haiku-release.cdn.haiku-os.org/testing/r1beta6/x86_64/haiku-r1beta6-hrev59866_53-x86_64-anyboot.iso"
]
