{ pkgs, lib, ... }: }
  imports = [
    ./module1.nix
    ./module2.nix
    ./module3.nix
    ./module4.nix
  ];

  module2.enable = lib.mkDefault true;
  module3.enable = lib.mkDefault true;
}
