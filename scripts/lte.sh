#!/bin/bash
# install: sudo ./scripts/lte.sh setup
# use: sudo lte up

if [[ "$1" = "" ]]; then
  echo "nothing to do, try with up, down, setup or remove"
  exit 1
fi

SCRIPT_PATH=$(readlink -f $0)
SCRIPT_DIR=`dirname $SCRIPT_PATH`
CONF_FILE=$SCRIPT_DIR/../xmm7360.ini

# run as root (Ubuntu GUI Tested)
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root, elevating!" 
  exec sudo $SCRIPT_DIR/lte.sh $1
  exit 0
fi

# switch to correct directory
cd $SCRIPT_DIR/..

echo "lte.sh: manage xmm7360-pci"
echo "APN: $apn"
echo "Script: $SCRIPT_DIR/lte.sh; Link: $BIN_DIR"
echo ""

# install deps, module, and lte script to PATH
if [[ "$1" = "setup" ]]; then
  pip install pyroute2 configargparse dbus-python --user
  unlink /usr/local/bin/lte || true
  ln -s $SCRIPT_DIR/lte.sh /usr/local/bin/lte
  chmod 755 /usr/local/bin/lte

  make
  make load
fi

# remove interface, mod
if [[ "$1" = "remove" ]]; then
  ip link set wwan0 down
  rmmod xmm7360 || true
  unlink /usr/local/bin/lte || true
fi

# down param
if [[ "$1" = "down" ]]; then
  echo "taking wwan0 down!" 
  ip link set wwan0 down
  exit
fi

if [[ "$1" = "up" ]]; then
  echo "bringing wwan0 up!" 

  python3 $SCRIPT_DIR/../rpc/open_xdatachannel.py --apn smartsites.t-mobile --nodefaultroute --noresolv --dbus
  ip link set wwan0 up
fi
