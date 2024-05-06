{ pkgs, lib, inputs, ... }: {
  imports = [
    inputs.disko.nixosModules.default
    ./disk-device.nix
    ./configuration.nix
    ./hardware-configuration.nix
  ];
}
