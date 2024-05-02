{ config, pkgs, ... }:
{
  home.username = "drgn";
  home.homeDirectory = "/static/u/drgn";

  home.stateVersion = "23.11"; # could have this follow system.stateVersion ... potential problems if i do that...

  programs.home-manager.enable = true;

		
}
