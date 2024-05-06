# exampleModule.nix 
{ pkgs, lib, config, ... }: {
  options = {
    module1.enable = lib.mkEnableOption "enables module1";
  };

}
