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
| r1beta4 | ✓      |

## Building Locally

### Prerequisite

* [Packer](https://www.packer.io) 1.7.2 or later
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
at the path: `output/haiku-r1beta4-x86-64.qcow2`.

## Additional Information

The qcow2 format is chosen because unused space doesn't take up any space on
disk, it's compressible and easily converts the raw format.
