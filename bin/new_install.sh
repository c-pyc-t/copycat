#!/bin/bash
# new_install.sh
#
# description: install nixos on a new system
# @niceguy
#
# usage:
#   remotely: sh <(curl imp.nz)
#   locally: sh .. bin/new_install.sh
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

PHASE=""

[[ $1 == "" ]] && PHASE="live"

case $PHASE in
        base) echo "Installing copycat:base" ;;
        perennial) echo "Installing copycat:perennial" ;;
        live) echo "Installing copycat:live" ;;
        *) echo "cant figure out wtf you want to do" && exit 1 ;;
esac

[[ ! `whoami` == "root"  ]] && echo "Must be run as root.." && exit 1

echo "THIS WILL NUKE WHATEVER DEVICE YOU POINT IT AT WITHOUT CHECKS AND SAFETY, YOU HAVE BEEN WARNED"

echo "Enter your device name [nvme0n1]: "
read DISK_DEV
[[ $DISK_DEV == "" ]] && DISK_DEV="nvme0n1";
echo "[/dev/$DISK_DEV] ... is this correct?"
read -n1 -r -p " to confirm [y|enter] : " CHOICE
case $CHOICE in
  y|Y|"") echo "" ;;
  *) exit 1 ;;
esac

pushd /tmp
nix-shell -p git --run "git clone https://github.com/nice-0/copycat.git"
nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko /tmp/copycat/base/disko.nix --arg device '"/dev/'${DISK_DEV}'"'

nixos-generate-config --no-filesystems --root /mnt # do we just need files to exist in /mnt/etc/nixos?

nix-shell -p git --run "git clone https://github.com/nice-0/copycat.git ."
nixos-generate-config --no-filesystems --root /mnt --dir /copycat/base

pushd /mnt/copycat/base

echo "#WARNING: DO NOT TOUCH ./_origin-version.nix UNLESS ABSOLUTELY CERTAIN YOU KNOW WHAT YOU'RE DOING" > _origin-version.nix
echo "{" >> _origin-version.nix
cat configuration.nix | grep "system.stateVersion" >> _origin-version.nix
echo "}" >> _origin-version.nix

mv /mnt/copycat/.git /tmp/ccgit 
nixos-install --flake /mnt/copycat#live
mv /tmp/ccgit /mnt/copycat/.git


# mkdir -p /mnt/copycat/base
# pushd /mnt/copycat/base
# mv /tmp/disko.nix .
# mv /mnt/etc/nixos/* .
#
#
#
# curl https://raw.githubusercontent.com/dolevep/nixos/main/base/flake.nix -o flake.nix
# sed -i "s/nvme0n1/$DISK_DEV/g" flake.nix
# curl https://raw.githubusercontent.com/dolevep/nixos/main/base/configuration.nix -o configuration.nix# sed -

