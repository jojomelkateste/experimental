#!/bin/sh

# Check if we are root:
if [ "$(id -u)" != "0" ]; then
  echo "$0 must be run as root." 1>&2
  exit 1
fi

# Defaults:
LIB_DIR=/usr/lib
INCLUDE_DIR=/usr/include
UDEV_RULES_DIR=/etc/udev/rules.d

if [ -d /usr/lib/x86_64-linux-gnu ]; then
  LIB_DIR=/usr/lib/x86_64-linux-gnu
fi

# Install library:
cp -vfd libtiepie.so* ${LIB_DIR}

# Install headers:
cp -vf C/libtiepie.h ${INCLUDE_DIR}
cp -vf C/libtiepiematlab.h ${INCLUDE_DIR}
cp -vf C++/libtiepie++.h ${INCLUDE_DIR}

# Install udev rules:
cp -vf 45-tiepie.rules ${UDEV_RULES_DIR}

# Reload udev rules
echo "Reloading udev rules."
udevadm control --reload-rules