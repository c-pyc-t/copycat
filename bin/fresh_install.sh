#!/bin/bash
# copycat.sh
#
# description: install nixos on a new system
# @drgn
#
# usage:
#   remotely: sh <(curl imp.nz/i)
#   locally: sh .. bin/copycat.sh
#
[[ ! `whoami` == "root"  ]] && echo "Must be run as root.." && exit 1

set -e

DEST_DEV=""
SWAP_SIZE=""

alias psak=$(read -t 5 -n 1 -s -r -p "Press any key to continue")

clear 

echo ""
echo ""
echo "                                                   ╻"
echo "           ┏━━━┓ ┏━━━┓ ┏━━━┓ ╻   ╻ ┏━━━┓ ┏━━━┓ ━━━━┫"
echo "       d   ┃     ┃   ┃ ┃   ┃ ┃   ┃ ┃     ┃   ┃     ┃"
echo "       r   ┃     ┃ / ┃ ┃   ┃ ┃   ┃ ┃     ┃   ┃     ┃"
echo "       g @ ┃     ┃   ┃ ┃   ┃ ┃   ┃ ┃     ┃   ┃     ┃"
echo "       n   ┗━━━┛ ┗━━━┛ ┣━━━┛ ┗━━━┫ ┗━━━┛ ┗━━─┃     ┃"
echo "                       ┃         ┃"
echo "                                                  24"
echo ""
echo "        I'm a bad girl, but a good story where I go."
echo "  I've nothing in my pockets but everything to show."
echo ""
echo "" 

psak

## DISK HEAD
## COPY IN TOTAL - WE NEED TO DO SOME ANNOYING CONDITIONALS
if [[ ! -d '/mnt/copycat' ]]; then


echo "THIS WILL NUKE WHATEVER DEVICE YOU POINT IT AT, WITHOUT CHECKS AND BALANCES, YOU HAVE BEEN WARNED."
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
	pushd /mnt/copycat
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

#nixos-generate-config --no-filesystems --root /mnt --dir /mnt/etc/nixos
nixos-generate-config --no-filesystems --root /mnt --dir /mnt/copycat/cfg/local_origin

#nix-shell -p git --run "git config --global user.email \"copycat@imp.nz\" && git config --global user.name \"copycat\" && git add -A && git commit -a --allow-empty-message -m 'enjoy your new system'"


# KEY GENERATION

pushd /mnt/copycat > /dev/null

# seems like keygen will have to be done before install as well 
mkdir -p /mnt/copycat/keys/sys/sec 2> /dev/null
mkdir -p /mnt/copycat/keys/sys/ssh 2> /dev/null

# id like to use higher than 4096, but 4096 is pretty much the highest 'standard' around
# in short, it's doable, it just isn't a good idea, yet.
nix --extra-experimental-features "nix-command flakes" shell nixpkgs#openssh -c \
		ssh-keygen -f \
			/mnt/copycat/keys/sys/ssh_system.key -t ed25519 -b 4096 -N '' -C "copycat@c-pyc-t@imp"

nix --extra-experimental-features "nix-command flakes" shell nixpkgs#ssh-to-age -c \
		ssh-to-age -private-key -i \
			/mnt/copycat/keys/sys/ssh_system.key > \
			/mnt/copycat/keys/sys/age.key 


# If I were serious and had something valuable to share I SHOULD have pgp (gpg) key for signing
# Just for verification.
# Thinking about this, this is likely something I could use to tag photos
# that or doing the whole blockchain thing ... yknow properly
# people really have no fucking clue how to use blockchain yknow... its also actually money.
# to really do it youd need buy in from fintech in general though.
# pipe dreams aside, put me on the front lines after all.

# INSTALLATION
sed -i "s/local_origin/LOCAL_ORIGIN/g" .gitignore
sed -i "s/flake.lock/FLAKE.LOCK/g" .gitignore

# This is an intentionally 'dumb' commit - meaning it just wants to commit to complete
# the install ... 
# in short, make sure as shit this DOESN'T propagate 
nix-shell -p git --run "
	git config user.email \"copycat@imp.nz\" && 
	git config user.name \"copycat\" && 
	git add -A && 
	git commit -a --allow-empty-message -m 'enjoy your new system ~mew.'"


nix-shell -p git --run "nixos-install --impure --root /mnt --flake /mnt/copycat/cfg#default"
# divergent git paths somewhere around here need to figure out how to do this cleanly/properly

sed -i "s/LOCAL_ORIGIN/local_origin/g" .gitignore
sed -i "s/FLAKE.LOCK/flake.lock/g" .gitignore

nix-shell -p git --run "
	git stash
"



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
# echo "  @drgn"
# echo ""
# echo    "Press any key to reboot..."
# read -p "     <C-c>-c-c-to-caaancel" && reboot
#
#
