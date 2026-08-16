# Haiku Builder

This project builds the Haiku VM image for the
[cross-platform-actions/action](https://github.com/cross-platform-actions/action)
GitHub action. The image contains a standard Haiku installation.

The following packages are installed as well:

* bash
* curl
* rsync

Since Haiku is not a multiuser system, there's only one user named `user`.

## Architectures and Versions

The following architectures and versions are supported:

| Version | x86-64 |
|---------|--------|
| r1beta6 | ✓      |
| r1beta5 | ✓      |

Note, R1/beta6 has not been officially released yet. The image is built from
the official test build, `hrev59866_53`, until the release is out.

Note, the R1/beta5 image is no longer built. The Haiku project removed the
R1/beta5 package repositories when releasing R1/beta6, which makes `pkgman`
fail during provisioning. The image from the `v0.1.0` release, the last one
that could be built, is reused for every release instead. It's still tested on
every build, just not rebuilt.

## Building Locally

### Prerequisite

* [Packer](https://www.packer.io) 1.12.0 or later
* [QEMU](https://qemu.org)

### Building

1. Clone the repository:
    ```
    git clone https://github.com/cross-platform-actions/haiku-builder
    cd haiku-builder
    ```

2. Run `build.sh` to build the image:
    ```
    ./build.sh <version> <architecture>
    ```
    Where `<version>` and `<architecture>` are the any of the versions or
    architectures available in the above table.

The above command will build the VM image and the resulting disk image will be
at the path: `output/haiku-r1beta5-x86-64.qcow2`.

## Additional Information

The qcow2 format is chosen because unused space doesn't take up any space on
disk, it's compressible and easily converts the raw format.
