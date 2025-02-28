#/usr/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script as root or with sudo."
    exit 1
fi

# Enable systemd in WSL2 (Check before adding)
echo "Configuring WSL2 to use systemd..."
if grep -q "systemd = true" /etc/wsl.conf || grep -q "systemd=true" /etc/wsl.conf ; then
    echo "Systemd is already enabled in /etc/wsl.conf."
else
    echo "[boot]" >> /etc/wsl.conf
    echo "systemd = true" >> /etc/wsl.conf
    echo "Systemd configuration added to /etc/wsl.conf."
fi

# Set up SIA Proxy in /etc/environment (Check before adding)
echo "Configuring system-wide proxy settings..."

if grep -q "http_proxy" /etc/environment; then
    echo "Proxy settings already exist in /etc/environment."
else
    cat <<EOL >> /etc/environment

# SIA Proxy Configuration
http_proxy="http://sia-lb.telekom.de:8080"
https_proxy="http://sia-lb.telekom.de:8080"
no_proxy="localhost,127.0.0.1,.telekom.de,.t-systems.com"
EOL
    echo "Proxy settings added to /etc/environment."
fi

# Create profile script to set proxy during login/startup (Check before creating)
echo "Creating profile script for proxy..."

if [ -f /etc/profile.d/proxy.sh ]; then
    echo "Profile script already exists at /etc/profile.d/proxy.sh."
else
    cat <<EOL > /etc/profile.d/proxy.sh
export http_proxy="http://sia-lb.telekom.de:8080"
export https_proxy="http://sia-lb.telekom.de:8080"
export no_proxy="localhost,127.0.0.1,.telekom.de,.t-systems.com"
EOL

    # Make the profile script executable
    chmod +x /etc/profile.d/proxy.sh
    echo "Profile script created and made executable."
fi

# Detect the Windows username and configure .wslconfig
WIN_USER=$(ls /mnt/c/Users | grep -E '^[A-Za-z0-9._-]+$' | head -n 1)
WSLCONF_PATH="/mnt/c/Users/$WIN_USER/.wslconfig"

echo "Detected Windows Username: $WIN_USER"
echo "Configuring WSL2 networking in $WSLCONF_PATH ..."

# Check if the .wslconfig file exists, create if not, and configure it
if [ -f "$WSLCONF_PATH" ]; then
    echo ".wslconfig file already exists. Checking for required settings..."

    # Check and add [wsl2] section if necessary
    if ! grep -q "\[wsl2\]" "$WSLCONF_PATH"; then
        echo "[wsl2]" >> "$WSLCONF_PATH"
    fi

    # Add or update dnsTunneling and networkingMode
    if ! grep -q "dnsTunneling=true" "$WSLCONF_PATH"; then
        echo "dnsTunneling=true" >> "$WSLCONF_PATH"
    fi

    if ! grep -q "networkingMode=mirrored" "$WSLCONF_PATH"; then
        echo "networkingMode=mirrored" >> "$WSLCONF_PATH"
    fi

    echo ".wslconfig updated successfully."
else
    # Create the file if it doesn't exist
    cat <<EOL > "$WSLCONF_PATH"
[wsl2]
dnsTunneling=true
networkingMode=mirrored
EOL
    echo "$WSLCONF_PATH created with [wsl2] configuration."
fi

# Completion message
echo "WSL2 configuration and proxy setup completed successfully!"
echo "Please restart your WSL2 instance for the changes to take effect."
