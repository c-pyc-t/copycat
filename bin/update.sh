#!/bin/bash
# this needs to be done better ...


cd /etc/nixos/
git pull origin main
nixos-reload --flake /etc/nixos#copycat switch

