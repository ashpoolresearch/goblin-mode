#!/bin/bash

SUDOERS_FILE="/etc/sudoers.d/claude-automate"
USER=$(whoami)

case "$1" in
  on)
    echo "Enabling passwordless sudo for Claude-safe commands..."
    sudo tee "$SUDOERS_FILE" > /dev/null << EOF
$USER ALL=(ALL) NOPASSWD: /usr/bin/apt, /usr/bin/apt-get, /usr/bin/dpkg, /usr/bin/snap
$USER ALL=(ALL) NOPASSWD: /usr/bin/systemctl, /usr/bin/journalctl
$USER ALL=(ALL) NOPASSWD: /usr/bin/ufw
$USER ALL=(ALL) NOPASSWD: /usr/bin/tee, /usr/bin/cp, /usr/bin/mv, /usr/bin/mkdir, /usr/bin/chmod, /usr/bin/chown
$USER ALL=(ALL) NOPASSWD: /usr/bin/docker, /usr/bin/docker-compose
$USER ALL=(ALL) NOPASSWD: /usr/sbin/nginx, /usr/sbin/apachectl
EOF
    sudo chmod 440 "$SUDOERS_FILE"
    sudo visudo -cf "$SUDOERS_FILE" && echo "ON — Claude can now sudo whitelisted commands." || {
      echo "Syntax error — removing broken file."
      sudo rm "$SUDOERS_FILE"
      exit 1
    }
    ;;
  off)
    if [ -f "$SUDOERS_FILE" ]; then
      sudo rm "$SUDOERS_FILE"
      echo "OFF — Claude sudo access removed."
    else
      echo "Already off."
    fi
    ;;
  status)
    if [ -f "$SUDOERS_FILE" ]; then
      echo "ON"
      echo "Whitelisted commands:"
      sudo cat "$SUDOERS_FILE"
    else
      echo "OFF"
    fi
    ;;
  add)
    if [ -z "$2" ]; then
      echo "Usage: claude-sudo.sh add /path/to/command"
      exit 1
    fi
    if [ ! -f "$SUDOERS_FILE" ]; then
      echo "Turn it on first: claude-sudo.sh on"
      exit 1
    fi
    # append to the existing file
    echo "$USER ALL=(ALL) NOPASSWD: $2" | sudo tee -a "$SUDOERS_FILE" > /dev/null
    sudo visudo -cf "$SUDOERS_FILE" && echo "Added $2" || {
      echo "Syntax error — reverting."
      sudo sed -i "\|$2|d" "$SUDOERS_FILE"
      exit 1
    }
    ;;
  remove)
    if [ -z "$2" ]; then
      echo "Usage: claude-sudo.sh remove /path/to/command"
      exit 1
    fi
    sudo sed -i "\|$2|d" "$SUDOERS_FILE"
    echo "Removed $2"
    ;;
  *)
    echo "Usage: claude-sudo.sh {on|off|status|add /path/to/cmd|remove /path/to/cmd}"
    ;;
esac
