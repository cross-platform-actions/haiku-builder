# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Add support for Haiku R1/beta6. Since it has not been officially released
    yet, the image is built from the official test build, `hrev59866_53`
- Add an `iso_urls` variable, which overrides where the installation ISO is
    downloaded from. This makes it possible to build versions that are not
    available on the release mirrors yet

### Changed
- The R1/beta5 image is copied from the `v0.1.0` release instead of being
    rebuilt. The Haiku project removed the R1/beta5 package repositories when
    releasing R1/beta6, which makes `pkgman` fail during provisioning. The
    image is still tested on every build

## [0.1.0] - 2026-04-29
### Changed
- Enable immutable releases ([action#140](https://github.com/cross-platform-actions/action/issues/140))

## [0.0.2] - 2025-12-12
### Fixed
- Fix non-fully qualified hostname ([action#113](https://github.com/cross-platform-actions/action/issues/113))

## [0.0.1] - 2025-05-19
### Added
- Initial release

[Unreleased]: https://github.com/cross-platform-actions/haiku-builder/compare/v0.1.0...HEAD

[0.1.0]: https://github.com/cross-platform-actions/haiku-builder/compare/v0.0.2...v0.1.0

[0.0.2]: https://github.com/cross-platform-actions/haiku-builder/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/cross-platform-actions/haiku-builder/releases/tag/v0.0.1
