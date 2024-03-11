# configuration.nix
# @niceguy
# auto-last-edit-date-here-would-be-swell-templates-could-be-useful-you-lazy-fuck
# unsure how flake.nix really works - but it seems that it comes before the config file - disk config is there.
#
# /static
#
# my system(s? eventually), will have a /static directory, this is basically 'data', a logical, cental 
# point for all mutable data.
# 
# good place for a home directory, no?
# 
# thus: /static/u/niceguy
#   = /static/ (data) -> u/ (users) -> name (name of user)
#
# along the same line of thinking, using btrfs labels, id like to keep my entire system configuration isolated 
# thus /copycat and the copycat user group are made and now we have user level access to make changes
# and only requiring root once we would like to commit / rebuild / switch
#
# in my mind configuration is a bucket containing all the others, but it might be worth tying to reframe
# my thinking to flake contains hardware-configuration and configuration which contains system-configuration / 
# and then becomes either system-configuration is the end point or home-manager or whatever other alternative there 
# might be out there.
# 
# hardware-configuration is already separate from the rest, 
# following convention I make configuration.nix my base
# including some initial user passwords and such
# and following our disko configuration. 
# 
# once used these are largely left untouched/changed unless a physical system rebuild occurs,
# you're spinning up on a new device, or conventions/standards within nix force an update.
#
# that leaves system-configuration.nix which because it has all the others as a 'base' 
# thus we should probably import at the END of our configuration.
#
# this means ultimately our entire system will be 
# 
#	./_origin-version.nix
# ./flake.nix
# ./hardware-configuration.nix    
# ./configuration.nix							<- you're here now
# ./system-configuration.nix
#
#	system-configuration in theory is actually doing some of the work of home-manager, but the beauty of this setup is
# should i want to piece out i only need to adjust the system-configuration and my local home.nix file 
# 
# this level of separation into logical chunks makes it very easy to work with
# the most important thing to be very VERY CAREFUL of is, do not let this balloon, it can be very
# difficult to untether a bunch of interlinking config files - so having this 'plan' to stick to means 
# we hopefully avoid that in the future but still allow for extensibility.
# 
#WARNING: DO NOT TOUCH `./_origin-version.nix` UNLESS ABSOLUTELY CERTAIN YOU KNOW WHAT YOU'RE DOING

{ pkgs, lib, inputs, ... }:

{
	imports = 
		[
			# --v-- ./flake.nix --v--
			# -+v+- ./configuration.nix -+v+- 
			../base/_origin-version.nix
			../base/hardware-configuration.nix
			# -+^+- ./configuration.nix -+^+-
			# ...
		];

		# NixOS SETTINGS
		nix.settings.experimental-features = [ "nix-command" "flakes" ];


		# BOOTLOADER
		# As much as I think I would prefer to use systemd on principle
		# Being able to do "nixos-rebuild switch -p test" to make a new profile/submenu is actually pretty dope... 
		# test this now ...

		# systemd
		# boot.loader.systemd-boot.enable = true;
		#	boot.loader.efi.canTouchEfiVariables = true;
		# boot.loader.systemd-boot.memtest86.enable = true;

		# grub
#		boot.loader.systemd-boot.enable = false;
		boot.loader.grub.enable = true;
		boot.loader.grub.device = "nodev";
		boot.loader.grub.efiSupport = true;
		boot.loader.grub.efiInstallAsRemovable = true;
		# generationsDir /copy kernels etc looks interesting for the way we want our generations to work


		# KERNEL
		boot.kernelPackages = pkgs.linuxPackages_zen;


		# LOCALE/LOCALIZATION
		time.timeZone = "Pacific/Auckland";
		i18n.defaultLocale = "en_NZ.UTF-8";


		# NETWORKING
		networking.hostName = "copycat";
		# This left here as an example of including more hosts entries and firewall rules 
		# networking.extraHosts = ''
		# 	127.0.0.2 other-localhost 
		# '';
		# networking.firewall.allowedTCPPorts = [ 22 ];
		# networking.firewall.allowTCPPortRanges = [
		# 	{ from = 69; to 169; }
		# ];
		# services.openssh.enable = true; # this automatically opens port 22 which we explicitly open above just for examples sake
		
		# networking management - probably swap off networkmanager the ugly pos...
		networking.networkmanager.enable = true;
		networking.firewall.enable = true;
		services.openssh = {
			enable = true;
			settings.PasswordAuthentication = false;
			settings.KbdInteractiveAuthentication = false;
			settings.PermitRootLogin = "no";
		};
		
		#	AUTOMATIC UPDATES
		# Scary! lets see how she handles it
		# You can keep a NixOS system up-to-date automatically by adding the following to configuration.nix:
		# system.autoUpgrade.enable = true;
		# system.autoUpgrade.allowReboot = false;
		system.autoUpgrade = {
			enable = true;
			flake = inputs.self.outPath;
			flags = [
				"--update-input"
				"nixpkgs"
				"-L"
			];
			dates = "09:00";
			randomizedDelaySec = "30min";
		};

		# This enables a periodically executed systemd service named nixos-upgrade.service. If the allowReboot option is false, it runs nixos-rebuild switch --upgrade to upgrade NixOS to the latest version in the current channel. (To see when the service runs, see systemctl list-timers.) If allowReboot is true, then the system will automatically reboot if the new generation contains a different kernel, initrd or kernel modules. You can also specify a channel explicitly, e.g.
		# system.autoUpgrade.channel = "https://channels.nixos.org/nixos-23.11";

		# GROUP SETUP
		users.groups.copycat = {};

		# DIRECTORY SETUP
		# run systemd-tmpfiles --clean to remove superfluous files
		# 
		# worth noting this will only be used for creation/updating automagically - it will create new in place what it says (meaning it will overwrite permissions but its not moving the directory), will also not remove anything without a clean
		systemd.tmpfiles.rules = [
			"d /static 755 root users ~7d"	# holds data within /static for 7d, will NOT remove files/directories immediately inside
			"d /static/u 755 root users"
			"d /copycat 775 root copycat"  # this will be where our actual system configuration will live in perpetuity
			"d /copycat/base 744 copycat root"
			"d /copycat/perennial 744 copycat root"
			"d /copycat/live 775 copycat copycat"
		];
#			DO NOT ADD UNLESS YOU'RE ACTIVELY USING SHIT, BE EXPLICIT, BE PURPOSEFUL
#			EXAMPLES: 
#			"d /static/testing 755 niceguy users 30s" # 30second hold time for testing - could be some interesting applications to this...
#			"d /static/data 755 niceguy users"
#			"d /static/transient 777 niceguy users 1d" # conceptually use this for downloading rando source for compliation and testing etc

		# SYSTEM PACKAGES
		# Allow unfree packages 
		nixpkgs.config.allowUnfree = true;

		# LD FIX (TY No Boilerplate) - https://nix.dev/guides/faq.html
		programs.nix-ld.enable = true;
		programs.nix-ld.libraries = with pkgs; [
			# Add any missing dynamic libraries for unpackaged
			#programs here, NOT in environment.systemPackages
		];

		programs.hyprland.enable = true;
#		programs.hyprland.package = inputs.hyprland.package."${pkgs.system}".hyprland; # apparently this is better but it doesnt work for me yet? typo?
		
		# dunno if i actually like fish ... use it for longer
		programs.fish.enable = true;
		users.defaultUserShell = pkgs.fish;


		# When you can add things with programs.PROGRAM - as there seems to be more support with the way it ties in
		environment.systemPackages = with pkgs; [
			vim
			neovim
			git
			lazygit
			home-manager
			kitty
			dunst
			wofi
			qutebrowser
		];


		# USER SETUP
		users.users."niceguy" = {
			isNormalUser = true;
			home = "/static/u/niceguy"; # make absolutely sure not to have a trailing slash on HOME dirs
			shell = pkgs.fish;
			description = "NiceGuy";
			initialPassword = ''\'';
			extraGroups = [ "wheel" "networkmanager" "copycat" ];
			# packages = with pkgs; [
			# ];
		};
		
		users.users.copycat = {
			isSystemUser = true;
			group = "copycat";
			extraGroups = [ "copycat" ];
		};
}

