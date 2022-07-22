#!/usr/bin/env bash

set -e

SSHD_DIR="$HOME/.config/sshd"
SSHD_CONF="$SSHD_DIR/sshd_config"
SYSTEMD_UNIT="sshd-user.service"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"

install_systemd_service() {
    echo "Installing systemd user service"
    mkdir -p "$SYSTEMD_USER_DIR"
    install -v -p "systemd/$SYSTEMD_UNIT" "$SYSTEMD_USER_DIR/$SYSTEMD_UNIT"

    echo "Reloading systemd user daemon"
    systemctl --user daemon-reload || true

    echo "Enabling and starting $SYSTEMD_UNIT"
    systemctl --user enable --now "$SYSTEMD_UNIT" || true
}

install_sshd() {
    if [ -f "$SSHD_CONF" ]; then
        echo "Skipping sshd configuration: sshd configuration already exists at $SSHD_CONF."
    else
        install_sshd_config
    fi

    generate_host_key dsa
    generate_host_key ecdsa
    generate_host_key ed25519
    generate_host_key rsa -b 4096
}

install_sshd_config() {
    mkdir -p "$SSHD_DIR"
    echo "Installing new configuration file at: $SSHD_CONF"
    cat > "$SSHD_CONF" <<CONF
HostKey $SSHD_DIR/ssh_host_dsa_key
HostKey $SSHD_DIR/ssh_host_ecdsa_key
HostKey $SSHD_DIR/ssh_host_ed25519_key
HostKey $SSHD_DIR/ssh_host_rsa_key
CONF
    cat ./sshd/sshd_config >> "$SSHD_CONF"
    echo
    cat "$SSHD_CONF"
    echo
}

generate_host_key() {
    key_file="$SSHD_DIR/ssh_host_$1_key"
    if [ ! -f "$key_file" ]; then
        echo "Generating ssh host key type: $1"
        ssh-keygen -q -N "" -t "$@" -f "$key_file"
    fi
}

do_help() {
    2>&1 echo "Please specify either install or uninstall"
}

do_install() {
    install_sshd
    install_systemd_service
}

do_uninstall() {
    echo "Stopping, disabling and removing systemd unit"
    systemctl --user disable --now "$SYSTEMD_UNIT" || true
    rm -v "$SYSTEMD_USER_DIR/$SYSTEMD_UNIT" || true

    if [ -d "$SSHD_DIR" ]; then
        echo
        echo "Found SSHD files in $SSHD_DIR."
        echo "If you don't need them please remove the directory or the files manually."
    fi
}

cd -- "$(dirname -- "$0")"

[[ -z "$XDG_RUNTIME_DIR" ]] && XDG_RUNTIME_DIR=/run/user/$UID
export XDG_RUNTIME_DIR

for arg; do
    [ "$arg" == "--help" ] && do_help && exit
done

case "$1" in
    install) do_install ;;
    uninstall) do_uninstall ;;
    help|--help) do_help ;;
    *) do_help; exit 1 ;;
esac
