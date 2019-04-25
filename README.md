
# Remote Backup

[![GitHub Release][releases-shield]][releases]
[![Build Status][travis-build-shield]][travis-build]
[![GitHub license][license-shield]](LICENSE.md)

> Automatically create Hass.io snapshots to remote server location using `SCP`.

<hr>

## Table of Contents

* [About](#about)
* [Installation](#installation)
* [Configuration](#configuration)
* [Example](#example)
* [Changelog & Releases](#changelog)
* [Docker status](#docker)

## <a name='about'></a>About

When the add-on is started the following happens:
1. Snapshot are being created locally with a timestamp name, e.g.
*Automatic backup 2018-03-04 04:00*.
1. The snapshot are copied to the specified remote location using `SCP`.
1. The local backup are removed locally again.

_Note_ the filenames of the backup are given by their assigned slug.

## <a name='installation'></a>Installation

1. Add the add-ons repository to your Hass.io instance: `https://github.com/overkill32/hassio-addons`.
1. Install the Remote Backup add-on.
1. Configure the add-on with your SSH credentials and desired output directory
(see configuration below).

See my [repository of addons][hassio-addons] for more information.

## <a name='configuration'></a>Configuration

|Parameter|Required|Description|
|---------|--------|-----------|
|`ssh_host`|Yes|The hostname/url to the remote server.|
|`ssh_port`|Yes|The port to use to `SCP` on to the server.|
|`ssh_user`|Yes|Username to use for `SCP`.|
|`ssh_key`|Yes|The ssh key to use. Not that it should *NOT* be password protected.|
|`remote_directory`|Yes|The directory to put the backups on the remote server.|
|`zip_password`|No|If set then the backup will be contained in a password protected zip|
|`keep_local_backup`|No|Control how many local backups you want to preserve. Default (`""`) is to keep no local backups created from this addon. If `all` then all loocal backups will be preserved. A positive integer will determine how many of the latest backups will be preserved. Note this will delete other local backups created outside this addon.

## <a name='example'></a>Example: daily backups at 4 AM

Personally I've added the following automation to make a daily backup. It is password-protected and the last two weeks of snapshots are kept locally as well.

_configuration.yaml_
```yaml
automations:
  - alias: Daily Backup at 4 AM
  trigger:
    platform: time
    at: '4:00:00'
  action:
  - service: hassio.addon_start
    data:
      addon: ce20243c_remote_backup
```

_Add-on configuration_:
```json
{
  "ssh_host": "192.168.1.2",
  "ssh_port": 22,
  "ssh_user": "root",
  "ssh_key": [
"-----BEGIN RSA PRIVATE KEY-----",
"MIICXAIBAAKBgQDTkdD4ya/Qxz5xKaKojVIOVWjyeyEoEuAafAvYvppqmaBhyh4N",
"5av4i87y8tdGusdq7V0Zj0+js4jEdvJRDrXJBrp1neLfsjkF6t1XLfrA51Ll9SXF",
"...",
"X+6r/gTvUEQv1ufAuUE5wKcq9FsbnTa3FOF0PdQDWl0=",
"-----END RSA PRIVATE KEY-----"
  ],
  "remote_directory": "~/hassio-backups",
  "zip_password": "password_protect_it",
  "keep_local_backup": "14"
}
```

**Note**: _This is just an example, don't copy and past it! Create your own!_

## <a name='changelog'></a>Changelog & Releases

This repository keeps a [change log](CHANGELOG.md). The format of the log
is based on [Keep a Changelog][keepchangelog].

Releases are based on [Semantic Versioning][semver], and use the format
of ``MAJOR.MINOR.PATCH``. In a nutshell, the version will be incremented
based on the following:

- ``MAJOR``: Incompatible or major changes.
- ``MINOR``: Backwards-compatible new features and enhancements.
- ``PATCH``: Backwards-compatible bugfixes and package updates.


## <a name='docker'></a>Docker status

[![Docker Architecture][armhf-arch-shield]][armhf-dockerhub]
[![Docker Version][armhf-version-shield]][armhf-microbadger]
[![Docker Layers][armhf-layers-shield]][armhf-microbadger]
[![Docker Pulls][armhf-pulls-shield]][armhf-dockerhub]

[![Docker Architecture][aarch64-arch-shield]][aarch64-dockerhub]
[![Docker Version][aarch64-version-shield]][aarch64-microbadger]
[![Docker Layers][aarch64-layers-shield]][aarch64-microbadger]
[![Docker Pulls][aarch64-pulls-shield]][aarch64-dockerhub]

[![Docker Architecture][amd64-arch-shield]][amd64-dockerhub]
[![Docker Version][amd64-version-shield]][amd64-microbadger]
[![Docker Layers][amd64-layers-shield]][amd64-microbadger]
[![Docker Pulls][amd64-pulls-shield]][amd64-dockerhub]

[![Docker Architecture][i386-arch-shield]][i386-dockerhub]
[![Docker Version][i386-version-shield]][i386-microbadger]
[![Docker Layers][i386-layers-shield]][i386-microbadger]
[![Docker Pulls][i386-pulls-shield]][i386-dockerhub]


[aarch64-arch-shield]: https://img.shields.io/badge/architecture-aarch64-blue.svg
[aarch64-dockerhub]: https://hub.docker.com/r/fixated/remote-backup-aarch64
[aarch64-layers-shield]: https://images.microbadger.com/badges/image/fixated/remote-backup-aarch64.svg
[aarch64-microbadger]: https://microbadger.com/images/fixated/remote-backup-aarch64
[aarch64-pulls-shield]: https://img.shields.io/docker/pulls/fixated/remote-backup-aarch64.svg
[aarch64-version-shield]: https://images.microbadger.com/badges/version/fixated/remote-backup-aarch64.svg
[amd64-arch-shield]: https://img.shields.io/badge/architecture-amd64-blue.svg
[amd64-dockerhub]: https://hub.docker.com/r/fixated/remote-backup-amd64
[amd64-layers-shield]: https://images.microbadger.com/badges/image/fixated/remote-backup-amd64.svg
[amd64-microbadger]: https://microbadger.com/images/fixated/remote-backup-amd64
[amd64-pulls-shield]: https://img.shields.io/docker/pulls/fixated/remote-backup-amd64.svg
[amd64-version-shield]: https://images.microbadger.com/badges/version/fixated/remote-backup-amd64.svg
[armhf-arch-shield]: https://img.shields.io/badge/architecture-armhf-blue.svg
[armhf-dockerhub]: https://hub.docker.com/r/fixated/remote-backup-armhf
[armhf-layers-shield]: https://images.microbadger.com/badges/image/fixated/remote-backup-armhf.svg
[armhf-microbadger]: https://microbadger.com/images/fixated/remote-backup-armhf
[armhf-pulls-shield]: https://img.shields.io/docker/pulls/fixated/remote-backup-armhf.svg
[armhf-version-shield]: https://images.microbadger.com/badges/version/fixated/remote-backup-armhf.svg
[i386-arch-shield]: https://img.shields.io/badge/architecture-i386-blue.svg
[i386-dockerhub]: https://hub.docker.com/r/fixated/remote-backup-i386
[i386-layers-shield]: https://images.microbadger.com/badges/image/fixated/remote-backup-i386.svg
[i386-microbadger]: https://microbadger.com/images/fixated/remote-backup-i386
[i386-pulls-shield]: https://img.shields.io/docker/pulls/fixated/remote-backup-i386.svg
[i386-version-shield]: https://images.microbadger.com/badges/version/fixated/remote-backup-i386.svg

[license-shield]: https://img.shields.io/github/license/overkill32/hassio-remote-backup.svg
[releases]: https://github.com/overkill32/hassio-remote-backup/releases
[releases-shield]: https://img.shields.io/github/release/overkill32/hassio-remote-backup.svg
[travis-build]: https://travis-ci.org/overkill32/hassio-remote-backup
[travis-build-shield]: https://travis-ci.org/overkill32/hassio-remote-backup.svg?branch=master

[keepchangelog]: http://keepachangelog.com/en/1.0.0/
[semver]: http://semver.org/spec/v2.0.0.html

[hassio-addons]: https://github.com/overkill32/hassio-addons
