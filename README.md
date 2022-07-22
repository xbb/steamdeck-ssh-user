# Run SSH server as user, no sudo, no password or SteamOS developer mode required

This scripts installs and enables a systemd unit in `~/.config/systemd/user/sshd-user.service`, which runs the SSH server as the current user.

This was built for the Steam Deck (SteamOS) but it should work on other platforms too. You may need to change the sftp subsystem path in the ssh server configuration file.

For the Steam Deck the service will start both in Desktop and Steam modes.

Configuration and host keys are found in: `~/.config/sshd`.

Default port is 2022.

## Install

Before installing, you can customize the file `sshd/sshd_config` to suit your needs, or you can do it
after installation in `~/.config/sshd/sshd_config` and restart the service.

HostKeys will be automatically generated during install, if they do not exist in `~/.config/sshd/`

Run the installer

```sh
./install.sh install
```

The installer enables and starts the service automatically, to check its status use:

```sh
systemctl --user status sshd-user
```

To login from a remote system, without password, you need to add your SSH public keys to `~/.ssh/authorized_keys`

If you need to change the SSH server configuration edit `~/.config/sshd/sshd_config` and restart the service with:

```sh
systemctl --user restart sshd-user
```

## Uninstall

To uninstall the service run

```sh
./installer.sh uninstall
```

SSH server configuration and host keys won't be removed.

If you want to remove them, delete the entire `~/.config/sshd` directory.

If you delete the host keys, when you reinstall they will be regenerated and you may need to reauthorized them from any connecting client.

## Tips

### SSH service logs

To check the log for any errors:

```sh
journalctl --user -xeu sshd-user
```

Everytime you login/logout, you may see an error like _"Attempt to write login records by non-root user (aborting)"_ in the log, which is "normal" when OpenSSH is run as non root. (<https://github.com/openssh/openssh-portable/blob/master/loginrec.c#L439>)

### SSH authorized_keys

If you added public keys to your GitHub account, you can download them from: `https://github.com/<username>.keys` and use those as your SSH authorized_keys file.

Example:

```sh
curl -o ~/.ssh/authorized_keys https://github.com/<yourusername>.keys
```

### Control systemd user services from SSH

If you use `systemctl --user` from an SSH session you may run into the error _"Failed to connect to bus: No medium found"_.

This is because the environment var `XDG_RUNTIME_DIR` needs to be set to the user run dir.

You can add the following to your `~/.bash_profile` to have it set and exported automatically for bash

```sh
[[ -z "$XDG_RUNTIME_DIR" ]] && XDG_RUNTIME_DIR=/run/user/$UID

export XDG_RUNTIME_DIR
```
