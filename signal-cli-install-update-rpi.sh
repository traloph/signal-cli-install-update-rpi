#!/bin/bash

# This script installs or updates the signal-cli and libsignal-client on a Raspberry Pi
# Run it from a location with write permissions, e.g. the home directory
# Makes use of the armv7 precompiled libsignal-client, make sure to understand the security implications of this

# Fetch the latest release number from GitHub
LATEST_VERSION=$(curl --silent "https://api.github.com/repos/AsamK/signal-cli/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')

# If no argument is given, use the latest version
if [ -z "$1" ]; then
    VERSION=$LATEST_VERSION
else
    VERSION=$1
fi

echo "Installing signal-cli version ${VERSION}..."

# Download the specified version
echo "Downloading signal-cli version ${VERSION}..."
wget https://github.com/AsamK/signal-cli/releases/download/v"${VERSION}"/signal-cli-"${VERSION}".tar.gz

# Extract the downloaded file
echo "Extracting the downloaded file..."
sudo tar xf signal-cli-"${VERSION}".tar.gz -C /opt

# Create a symbolic link
echo "Creating a symbolic link..."
sudo ln -sf /opt/signal-cli-"${VERSION}"/bin/signal-cli /usr/local/bin/

# Extract libsignal version from the jar file name
echo "Checking required version of libsignal..."
LIBSIGNAL_VERSION=$(ls /opt/signal-cli-"${VERSION}"/lib/libsignal-client-*.jar | grep -oP 'libsignal-client-\K.*(?=.jar)')

# Download the required libsignal version
echo "Downloading libsignal version ${LIBSIGNAL_VERSION}..."
wget https://github.com/exquo/signal-libs-build/releases/download/libsignal_v"${LIBSIGNAL_VERSION}"/libsignal_jni.so-v"${LIBSIGNAL_VERSION}"-armv7-unknown-linux-gnueabihf.tar.gz

# Unpack the libsignal file
echo "Unpacking the libsignal file..."
tar -xzf libsignal_jni.so-v"${LIBSIGNAL_VERSION}"-armv7-unknown-linux-gnueabihf.tar.gz

# Replace the bundled .so file in the jar
echo "Replacing the bundled .so file in the jar..."
sudo zip -uj /opt/signal-cli-"${VERSION}"/lib/libsignal-client-"${LIBSIGNAL_VERSION}".jar libsignal_jni.so

rm libsignal_jni.so