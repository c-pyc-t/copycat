{ config, pkgs, ... }:
{
  home.username = "drgn";
  home.homeDirectory = "/static/u/drgn";
  #FLAKE = "/copycat/system";

  home.stateVersion = "23.11"; # could have this follow system.stateVersion ... potential problems if i do that...

  programs.home-manager.enable = true;
  programs.git.enable = true;
  programs.neovim.enable = true;

  
}
