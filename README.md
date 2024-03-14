# SFTP Docker container

Easy to use hardened [SFTP](https://en.wikipedia.org/wiki/SSH_File_Transfer_Protocol) server based on Debian with [OpenSSH](https://en.wikipedia.org/wiki/OpenSSH).

Forked from [atmoz/sftp](https://github.com/atmoz/sftp) to tune a few things:

- Remove password based Auth, now key only
- Switch to Debian ~~Stretch~~, ~~Buster~~, ~~Bullseye~~, Bookworm

[![dockeri.co](http://dockeri.co/image/jujhars13/sftp)](https://hub.docker.com/r/jujhars13/sftp/)

## Supported tags and respective `Dockerfile` links

- [`v1.4.0`, `latest` (*Dockerfile*)](https://github.com/jujhars13/sftp/blob/v1.4.0/Dockerfile) [![](https://images.microbadger.com/badges/image/jujhars13/sftp.svg)](http://microbadger.com/images/jujhars13/sftp)
- [`v1.3.0`, (*Dockerfile*)](https://github.com/jujhars13/sftp/blob/v1.3.0/Dockerfile) [![](https://images.microbadger.com/badges/image/jujhars13/sftp.svg)](http://microbadger.com/images/jujhars13/sftp)
- [`v1.2.2`, (*Dockerfile*)](https://github.com/jujhars13/sftp/blob/v1.2.2/Dockerfile) [![](https://images.microbadger.com/badges/image/jujhars13/sftp.svg)](http://microbadger.com/images/jujhars13/sftp)
- [`v1.2.1`, (*Dockerfile*)](https://github.com/jujhars13/sftp/blob/v1.2.1/Dockerfile) [![](https://images.microbadger.com/badges/image/jujhars13/sftp.svg)](http://microbadger.com/images/jujhars13/sftp)
- [`v1.2`, (*Dockerfile*)](https://github.com/jujhars13/sftp/blob/v1.2/Dockerfile) [![](https://images.microbadger.com/badges/image/jujhars13/sftp.svg)](http://microbadger.com/images/jujhars13/sftp)
- [`v1.1`, (*Dockerfile*)](https://github.com/jujhars13/sftp/blob/v1.1/Dockerfile) [![](https://images.microbadger.com/badges/image/jujhars13/sftp.svg)](http://microbadger.com/images/jujhars13/sftp)
- [`v1.0` (*Dockerfile*)](https://github.com/jujhars13/sftp/blob/v1.0/Dockerfile) [![](https://images.microbadger.com/badges/image/jujhars13/sftp.svg)](http://microbadger.com/images/jujhars13/sftp)

## Usage

- Required: define users as command arguments, STDIN or mounted in `/etc/sftp/users.conf`
  (syntax: `user:pass[:e][:uid[:gid[:dir1[,dir2]...]]]...`).
  - Set UID/GID manually for your users if you want them to make changes to
    your mounted volumes with permissions matching your host filesystem.
  - Add directory names at the end, if you want to create them under the user's
    home directory. Perfect when you just want a fast way to upload something.
- Optional (but recommended): mount volumes.
  - The users are chrooted to their home directory, so you can mount the
    volumes in separate directories inside the user's home directory
    (/home/user/**mounted-directory**) or just mount the whole **/home** directory.
    Just remember that the users can't create new files directly under their
    own home directory, so make sure there are at least one subdirectory if you
    want them to upload files.
  - For consistent server fingerprint, mount your own host keys (i.e. `/etc/ssh/ssh_host_*`)

## Examples

### Sharing a directory from your computer

Let's mount a directory and set UID (we will also provide our own hostkeys):

```bash
docker run \
    -v /host/upload:/home/foo/upload \
    -v /host/ssh_host_rsa_key:/etc/ssh/ssh_host_rsa_key \
    -v /host/ssh_host_rsa_key.pub:/etc/ssh/ssh_host_rsa_key.pub \
    -p 2222:22 -d jujhars13/sftp \
    foo:pass:1001
```

### Using Docker Compose:

```yaml
sftp:
    image: jujhars13/sftp
    volumes:
        - /host/upload:/home/foo/upload
        - /host/ssh_host_rsa_key:/etc/ssh/ssh_host_rsa_key
        - /host/ssh_host_rsa_key.pub:/etc/ssh/ssh_host_rsa_key.pub
    ports:
        - "2222:22"
    command: foo:pass:1001
```

## Logging in

The OpenSSH server runs by default on port 22, and in this example, we are
forwarding the container's port 22 to the host's port 2222. To log in with the
OpenSSH client, run: `sftp -P 2222 foo@<host-ip>`

## Store users in config

```bash
docker run \
    -v /host/users.conf:/etc/sftp/users.conf:ro \
    -v mySftpVolume:/home \
    -v /host/ssh_host_rsa_key:/etc/ssh/ssh_host_rsa_key \
    -v /host/ssh_host_rsa_key.pub:/etc/ssh/ssh_host_rsa_key.pub \
    -p 2222:22 -d jujhars13/sftp
```

`/host/users.conf`:

```bash
foo:123:1001:100
bar:abc:1002:100
baz:xyz:1003:100
```

## Logging in with SSH keys

Mount public keys in the user's `.ssh/keys/` directory. All keys are
automatically appended to `.ssh/authorized_keys` (you can't mount this file
directly, because OpenSSH requires limited file permissions). In this example,
we do not provide any password, so the user `foo` can only login with his SSH
key.

```bash
docker run \
    -v /host/id_rsa.pub:/home/foo/.ssh/keys/id_rsa.pub:ro \
    -v /host/id_other.pub:/home/foo/.ssh/keys/id_other.pub:ro \
    -v /host/share:/home/foo/share \
    -p 2222:22 -d jujhars13/sftp \
    foo::1001
```

## Providing your own SSH host key

This container will generate new SSH host keys at first run. To avoid that your
users get a [MITM](https://en.wikipedia.org/wiki/Man-in-the-middle_attack) warning when you recreate your container (and the host keys
changes), you can mount your own host keys.

```bash
docker run \
    -v /host/ssh_host_ed25519_key:/etc/ssh/ssh_host_ed25519_key \
    -v /host/ssh_host_rsa_key:/etc/ssh/ssh_host_rsa_key \
    -v /host/share:/home/foo/share \
    -p 2222:22 -d jujhars13/sftp \
    foo::1001
```

Tip: you can generate your keys with these commands:

```bash
ssh-keygen -t ed25519 -f /host/ssh_host_ed25519_key < /dev/null
ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key < /dev/null
```

## Execute custom scripts or applications

Put your programs in `/etc/sftp.d/` and it will automatically run when the container starts.
See next section for an example.

## Bindmount dirs from another location

If you are using `--volumes-from` or just want to make a custom directory
available in user's home directory, you can add a script to `/etc/sftp.d/` that
bindmounts after container starts.

```bash
#!/bin/bash
# File mounted as: /etc/sftp.d/bindmount.sh
# Just an example (make your own)

function bindmount() {
    if [ -d "$1" ]; then
        mkdir -p "$2"
    fi
    mount --bind $3 "$1" "$2"
}

# Remember permissions, you may have to fix them:
# chown -R :users /data/common

bindmount /data/admin-tools /home/admin/tools
bindmount /data/common /home/dave/common
bindmount /data/common /home/peter/common
bindmount /data/docs /home/peter/docs --read-only
```

## What's the difference between Debian and Alpine?

The most obvious differences are in size and OpenSSH version.
[Alpine](https://hub.docker.com/_/alpine/) is 10 times smaller than
[Debian](https://hub.docker.com/_/debian/). OpenSSH version can also differ, as
it's two different teams maintaining the packages. Debian is generally
considered more stable and only bugfixes and security fixes are added after
each Debian release (about 2 years). Alpine has a faster release cycle (about 6
months) and therefore newer versions of OpenSSH. As I'm writing this, Debian
has version 6.7 while Alpine has version 7.4. Recommended reading:
[Comparing Debian vs Alpine for container & Docker apps](https://www.turnkeylinux.org/blog/alpine-vs-debian)

## Changelog

- 2020-12-18 switching out to Debian bullseye-slim
- 2020-12-18 switching out to Debian buster-slim
- 2018-11-6 bumping to get latest Deb w/patches
- 2018-01-5 bumping to get latest Deb w/patches
- 2017-10-6 bumping to get latest Debian Stretch w/ patches
