#!/bin/bash
# new_install.sh
#
# description: install nixos on a new system
# @drgn
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
set -e

SKIP_DISK=true

DEST_DEV=""
SWAP_SIZE=""

alias psak=$(read -t 5 -n 1 -s -r -p "Press any key to continue")

clear 

echo ""
echo ""
echo ""
echo "                                              ╻"
echo "      ┏━━━┓ ┏━━━┓ ┏━━━┓ ╻   ╻ ┏━━━┓ ┏━━━┓ ━━━━┫"
echo "  d   ┃           ┃   ┃ ┃   ┃ ┃               ┃"
echo "  r   ┃     ━━━━━ ┃   ┃ ┃   ┃ ┃     ━━━━━     ┃"
echo "  g @ ┃           ┃   ┃ ┃   ┃ ┃               ┃"
echo "  n   ┗━━━┛ ┗━━━┛ ┣━━━┛ ┗━━━┫ ┗━━━┛ ┗━━─┦     ╹"
echo "                  ┃         ┃									"
echo "                  ┃         ┃               24."
echo ""
echo ""
echo ""

psak
#echo "Do you wish to install this program?"
#select yn in "Yes" "No"; do
#    case $yn in
#        Yes ) make install; break;;
#        No ) exit;;
#    esac
#done
#


## DISK HEAD
## COPY IN TOTAL - WE NEED TO DO SOME ANNOYING CONDITIONALS
if [[ ! -d '/mnt/copycat' && ! $SKIP_DISK ]]; then

[[ ! `whoami` == "root"  ]] && echo "Must be run as root.." && exit 1

echo "THIS WILL NUKE WHATEVER DEVICE YOU POINT IT AT WITHOUT CHECKS AND SAFETY, YOU HAVE BEEN WARNED"
echo ""
echo ""
echo ""

psak

QVAR="nvme0n1"
CONTINUE=false
while ( ! $CONTINUE ); do 
	if [[ -e "/dev/$QVAR" ]]; then
		echo "destination: /dev/$QVAR [=]"
		CONTINUE=true
	else
		echo "destination: /dev/$QVAR [!]"
		echo "unrecognised destination, please enter /dev/\"trgtdev\""
	fi

	select OCE in "ok" "change" "escape";
	do
		case $OCE in
			ok )			[[ $CONTINUE ]] && break												;; 
			change )	CONTINUE=false && read -p "value: " QVAR; break	;;
			escape )  exit 1																					;;
		esac
	done
done
DISK_DEV=$QVAR
unset QVAR
unset CONTINUE

psak



QVAR="32GiB"
CONTINUE=false
while ( ! $CONTINUE ); do 
	echo "Swap size: $QVAR"
	CONTINUE=true

	select OCE in "ok" "change" "escape";
	do
		case $OCE in
			ok )			[[ $CONTINUE ]] && break												;; 
			change )	CONTINUE=false && read -p "value: " QVAR; break	;;
			escape )  exit 1																					;;
		esac
	done
done
SWAP_SIZE=$QVAR
unset QVAR
unset CONTINUE

psak


echo "Device: $DISK_DEV"
echo "Swap Size: $SWAP_SIZE"

echo "Beginning ..."
echo "Setting swap size ..." && sed -i "s/32GiB/$SWAP_SIZE/g" /tmp/copycat/cfg/disko/disko.nix
echo "Setting up disk ..." 

nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko /tmp/copycat/cfg/disko/disk-device.nix --arg device '"/dev/'${DISK_DEV}'"'

	nix-shell -p git --run "git clone https://github.com/c-pyc-t/copycat.git /mnt/copycat"

	nixos-generate-config --no-filesystems --root /mnt --dir /mnt/copycat/cfg/local_origin

else
	pushd /mnt/copycat > /dev/null
  nix-shell -p git --run "git stash"
	nix-shell -p git --run "git pull"
	rm -rf cfg/local_origin
	nixos-generate-config --no-filesystems --root /mnt --dir /mnt/copycat/cfg/local_origin
fi
# DISK FOOTER ABOVE



pushd /mnt/copycat/cfg/local_origin > /dev/null

echo "{" > version.nix
cat configuration.nix | grep "system.stateVersion" >> version.nix
echo "}" >> version.nix

nixos-generate-config --no-filesystems --root /mnt --dir /mnt/etc/nixos
nixos-generate-config --no-filesystems --root /mnt --dir /mnt/copycat/cfg/local_origin
nix-shell -p git --run "nixos-install --impure --root /mnt --flake /mnt/copycat/cfg#default"


####
# nix shell --extra-experimental-features "nix-command flakes" nixpkgs#git
####

#
# ### 
# # setup keys/secret/password shit
# #
#
# # from vimjoyer
# # generate new key at ~/.config/sops/age/keys.txt
# # nix shell nixpkgs#age age-keygen -o ~/.config/sops/age/keys.txt
#
# # generate new key at ~/.config/sops/age/keys.txt from private ssh key at ~/.ssh/private 
# # nix run nixpkgs#ssh-to-age -- -private-key -i ~/.ssh/private > ~/.config/sops/age/keys.txt
#
# # So it seems we should start from an SSH key that way we have all the necessary tools for our
# # systems key management - in theory i think of this more like a butler going back and forth 
# # fetching the correct things but i can step in to adjust things if needed unlike most other
# # authentication methods where a bunch of unknown shit happens... 
# #
# mkdir -p /mnt/copycat/keys
# pushd /mnt/copycat/keys
#
# ssh-keygen -f ./ssh.key -t ed25519 -b 4096 -N '' -C "copycat@copycat@copycat"
#
# # while possible to just simply generate the age.key from ssh.key, that being deterministic
# # gives me the heebies - i think ill just keep a unique age key for unlocking 'local' or internal-to-me
# # systems.
#
# # SSH -> AGE way [defunct for my purposes]
# # nix --experimental-features "nix-command flakes" run nixpkgs#ssh-to-age -- -private-key -i ./ssh.key > ./age.key
# # nix --experimental-features "nix-command flakes" shell nixpkgs#age -c age-keygen -y ./age.key > ./age.key.pub
#
# # AGE GENERATION
# nix --experimental-features "nix-command flakes" shell nixpkgs#age -c age-keygen -o age.key
#
# echo "# copycat ssh.key.pub" >> /tmp/pubs
# cat ssh.key.pub >> /tmp/pubs
#
# # this prints a public version to stdout (we pipe to termbin because boss)
# echo ""
# echo ""
# echo ""
# echo "-v- generating link ... -v-"
# cat /tmp/pubs | nc termbin.com 9999
# echo "-^- your systems PUBLIC SSH key should be in the link above -^-"
# echo ""
# echo ""
# echo ""
# echo "NOTE: age.key AND the 'public' key shouldn't leave my system "
# echo "      the public age key is to act like a canary."
# echo "			currently it doesn't, but it will give me an optional"
# echo "      extra layer of security should i want to implement it "
# echo "      in the future, and doesn't change the basic functionality"
# echo "      aka win/win ..."
# echo "  @niceguy"
# echo ""
# echo    "Press any key to reboot..."
# read -p "     <C-c>-c-c-to-caaancel" && reboot
#
#
