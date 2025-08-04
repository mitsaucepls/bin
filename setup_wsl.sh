#!/usr/bin/bash

PROXY_URL="http://sia-lb.telekom.de:8080"
NO_PROXY="localhost,127.0.0.1,.telekom.de,.t-systems.com"

INSTALL_DOCKER=false

parse_arguments() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      --docker)
        INSTALL_DOCKER=true
        shift
        ;;
      *)
        echo "Unknown option: $1"
        echo "Usage: $0 [--docker]"
        exit 1
        ;;
    esac
  done
}

check_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script as root or with sudo."
    exit 1
  fi
}

configure_systemd() {
  echo "Configuring WSL2 to use systemd..."
  if grep -q "systemd = true" /etc/wsl.conf || grep -q "systemd=true" /etc/wsl.conf ; then
    echo "Systemd is already enabled in /etc/wsl.conf."
  else
    echo "[boot]" >> /etc/wsl.conf
    echo "systemd = true" >> /etc/wsl.conf
    echo "Systemd configuration added to /etc/wsl.conf."
  fi
}

configure_system_proxy() {
  echo "Configuring system-wide proxy settings..."

  if grep -q "http_proxy" /etc/environment; then
    echo "Proxy settings already exist in /etc/environment."
  else
    cat <<EOL >> /etc/environment

# SIA Proxy Configuration
http_proxy="$PROXY_URL"
https_proxy="$PROXY_URL"
no_proxy="$NO_PROXY"
EOL
    echo "Proxy settings added to /etc/environment."
  fi
}

configure_profile_proxy() {
  echo "Creating profile script for proxy..."

  if [ -f /etc/profile.d/proxy.sh ]; then
    echo "Profile script already exists at /etc/profile.d/proxy.sh."
  else
    cat <<EOL > /etc/profile.d/proxy.sh
export http_proxy="$PROXY_URL"
export https_proxy="$PROXY_URL"
export no_proxy="$NO_PROXY"
EOL
    chmod +x /etc/profile.d/proxy.sh
    echo "Profile script created and made executable."
  fi
}

configure_wslconfig() {
  WIN_USER=$(ls /mnt/c/Users | grep -E '^[A-Za-z0-9._-]+$' | head -n 1)
  WSLCONF_PATH="/mnt/c/Users/$WIN_USER/.wslconfig"

  echo "Detected Windows Username: $WIN_USER"
  echo "Configuring WSL2 networking in $WSLCONF_PATH ..."

  if [ -f "$WSLCONF_PATH" ]; then
    echo ".wslconfig file already exists. Checking for required settings..."

    if ! grep -q "\[wsl2\]" "$WSLCONF_PATH"; then
      echo "[wsl2]" >> "$WSLCONF_PATH"
    fi

    if ! grep -q "dnsTunneling=true" "$WSLCONF_PATH"; then
      echo "dnsTunneling=true" >> "$WSLCONF_PATH"
    fi

    if ! grep -q "networkingMode=mirrored" "$WSLCONF_PATH"; then
      echo "networkingMode=mirrored" >> "$WSLCONF_PATH"
    fi

    echo ".wslconfig updated successfully."
  else
    cat <<EOL > "$WSLCONF_PATH"
[wsl2]
dnsTunneling=true
networkingMode=mirrored
EOL
    echo "$WSLCONF_PATH created with [wsl2] configuration."
  fi
}

check_docker_installed() {
  if command -v docker &> /dev/null; then
    return 0
  else
    return 1
  fi
}

configure_docker_proxy() {
  echo "Configuring Docker proxy settings..."
  mkdir -p /etc/systemd/system/docker.service.d
  cat <<EOL > /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="http_proxy=$PROXY_URL/"
Environment="https_proxy=$PROXY_URL/"
Environment="no_proxy=$NO_PROXY"
EOL

  if [ ! -f /etc/docker/daemon.json ]; then
    mkdir -p /etc/docker
    echo '{}' > /etc/docker/daemon.json
  fi

  cat <<EOL > /etc/docker/daemon.json
{
  "iptables": false,
  "dns": ["10.34.255.23", "10.33.255.23"]
}
EOL
  systemctl daemon-reload
  systemctl restart docker
  echo "Docker proxy configuration completed."
}

handle_docker_setup() {
  if [ "$INSTALL_DOCKER" = true ]; then
    echo "Docker configuration requested..."

    if check_docker_installed; then
      echo "Docker is already installed. Configuring proxy settings..."
      configure_docker_proxy
    else
      echo "Docker is not installed. Please install Docker first before running with --docker flag."
      echo "You can install Docker using your package manager or Docker's official installation script."
      exit 1
    fi
  fi
}

main() {
  parse_arguments "$@"
  check_root
  configure_systemd
  configure_system_proxy
  configure_profile_proxy
  configure_wslconfig
  handle_docker_setup

  echo "WSL2 configuration and proxy setup completed successfully!"
  if [ "$INSTALL_DOCKER" = true ]; then
    echo "Docker proxy configuration has been applied."
  fi
  echo "Please restart your WSL2 instance for the changes to take effect."
}

main "$@"
