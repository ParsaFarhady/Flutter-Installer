#!/bin/bash
# Requesting admin rights if not already running as admin
if [ "$(id -u)" -eq 0 ]; then
    echo "Already running as root."
else
    echo "Requesting administrative privileges..."
    sudo "$0"
    exit $?
fi

# Define variables
downloadURL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.19.5-stable.tar.xz"
installPath="/opt/flutter"
tempFolder="/tmp/FlutterInstaller"
zipFile="$tempFolder/flutter.tar.xz"

# Create temporary folder
mkdir -p "$tempFolder"

# Download Flutter tarball (tracking progress in MB)
echo "Downloading Flutter..."
wget --progress=dot:mega -O "$zipFile" "$downloadURL" 2>&1 | grep --line-buffered "%" | \
    sed -u -e "s,\.,,g" | awk '{printf("\b\b\b\b%4s", $2)}'

# Unzip Flutter
echo -e "\n\nExtracting Flutter..."
tar xf "$zipFile" -C "$installPath"

# Clean up temporary files
echo -e "\nCleaning up..."
rm -f "$zipFile"
rm -rf "$tempFolder"

# Add Flutter bin directory to PATH
echo "$PATH" | grep -q "$installPath/bin"
if [ $? -ne 0 ]; then
    echo "Adding Flutter to PATH..."
    echo "export PATH=\"$installPath/bin:\$PATH\"" >> ~/.bashrc
    source ~/.bashrc
fi

# Display completion message
echo -e "\nFlutter has been successfully installed."
echo -e "Please restart your terminal to start using Flutter.\n"
