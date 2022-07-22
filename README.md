# Steam Deck (and more?) SSHD as user, no sudo, no password required

The script installs a systemd unit file in `~/.config/systemd/user/sshd-user.service`
which runs sshd as the current user.

SSHD will work both in Desktop and Steam modes.

Configuration and host keys are found in: `~/.config/sshd`.

Default port is 2022.

## Install

NOTE: If you want before installation you can customize `sshd/sshd_config`, or you can do it later in `~/.config/sshd/sshd_config` and restart the service.

Run the installer

```sh
./install.sh install
```

Add your ssh public keys to `~/.ssh/authorized_keys`

TIP: if you have set your public keys in GitHub, you can download them from: `https://github.com/<username>.keys`

Change configuration if required and restart the user service with:

```sh
systemctl --user restart sshd-user
```

## Uninstall

Run

```
./installer.sh uninstall
```

SSHD configuration and host keys won't be removed. If you want remove the manually from `~/.config/sshd`.