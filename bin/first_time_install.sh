#!/bin/bash
# run.sh
#
# description: install nixos on a new system
# @niceguy
#
# usage:
#   remotely: sh <(curl imp.nz) 
#   locally: sh run.sh
#
# NOTES:
#   this is not very dynamic - yet, if i feel the need i'll update it to be so
#   importantly you will need to manually and preemptively handle the file names 
#   and device names currently 
#
#   ... (hey thats declaritive at least!) 
#
#
set -e

[[ ! `whoami` == "root"  ]] && echo "Must be run as root.." && exit 1

echo "Enter your device name [nvme0n1]: "

read DISK_DEV

[[ $DISK_DEV == "" ]] && DISK_DEV="nvme0n1";

echo "[/dev/$DISK_DEV] ... is this correct?"
read -n1 -r -p " to confirm [y|enter] : " CHOICE
case $CHOICE in
  y|Y|"") echo "wheeee";;
  *) echo "Fuckitbruh" && exit 1 ;;
esac

curl https://raw.githubusercontent.com/dolevep/nixos/main/base/disko.nix?$RANDOM -o /tmp/disko.nix

nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko /tmp/disko.nix --arg device '"/dev/'${DISK_DEV}'"'

nixos-generate-config --no-filesystems --root /mnt
mkdir -p /mnt/copycat/base
pushd /mnt/copycat/base
mv /tmp/disko.nix .
mv /mnt/etc/nixos/* .


echo "#WARNING: DO NOT TOUCH ./_origin-version.nix UNLESS ABSOLUTELY CERTAIN YOU KNOW WHAT YOU'RE DOING" > _origin-version.nix
echo "{" >> _origin-version.nix
cat configuration.nix | grep "system.stateVersion" >> _origin-version.nix
echo "}" >> _origin-version.nix
> configuration.nix

curl https://raw.githubusercontent.com/dolevep/nixos/main/base/flake.nix -o flake.nix
sed -i "s/nvme0n1/$DISK_DEV/g" flake.nix
curl https://raw.githubusercontent.com/dolevep/nixos/main/base/configuration.nix -o configuration.nix
echo "{}" > system-configuration.nix

nixos-install --flake /copycat/base#default

