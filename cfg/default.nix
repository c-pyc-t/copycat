# default.nix
# @drgn

{ pkgs, lib, inputs, ... }:

{
	imports = 
		[
			# --v-- ./flake.nix --v--
			# ./base/_origin-version.nix					# < --- all these moved to flake.nix
			# ...
		];

		# NixOS SETTINGS
		nix.settings.experimental-features = [ "nix-command" "flakes" ];

		environment.sessionVariables = {
			FLAKE = "/copycat/cfg";
		};

		# BOOTLOADER
		# systemd - shelved for now
		# boot.loader.systemd-boot.enable = true;
		# boot.loader.efi.canTouchEfiVariables = true;
		# boot.loader.systemd-boot.memtest86.enable = true;

		# grub
		boot.loader.grub.enable = true;
		boot.loader.grub.device = "nodev";
		boot.loader.grub.efiSupport = true;
		boot.loader.grub.efiInstallAsRemovable = true;


		# KERNEL
		boot.kernelPackages = pkgs.linuxPackages_zen;


		# LOCALE/LOCALIZATION
		time.timeZone = "Pacific/Auckland";
		i18n.defaultLocale = "en_NZ.UTF-8";


		# NETWORKING
#		networking.hostName = "copycat"; # this needs to be done in a specific configuration file - aka dont set this shit here.
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
		
	
		networking.enableIPv6 = false;

		networking.nameservers = [ "1.1.1.1" "8.8.8.8" "9.9.9.9" ];
		
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

		# BLUETOOTH
		hardware.bluetooth.enable = true;
		hardware.bluetooth.powerOnBoot = true;

		# AUDIO 
		# Remove sound.enable or set it to false if you had it set previously, as sound.enable is only meant for ALSA-based configurations

		# rtkit is optional but recommended
		security.rtkit.enable = true;
		services.pipewire = {
		  enable = true;
		  alsa.enable = true;
		  alsa.support32Bit = true;
			pulse.enable = true;
		  # If you want to use JACK applications, uncomment this
			#jack.enable = true;
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
			# STATIC PERMISSIONS
			"d /static 755 root users"	
			"d /static/u 755 root users"

			# CONSOLE PERMISSIONS
			"d /static/console 770 root copycat"
			"d /static/console/sec 750 root copycat"
			"f /static/console/sec/sys 750 root copycat"
			"f /static/console/sec/sys/age.key 600 copycat copycat"
			"f /static/console/sec/sys/ssh_system.key 600 copycat copycat"
			"f /static/console/sec/sys/ssh_system.key.pub 644 copycat copycat"

			# NIXOS CONFIGURATION PERMISSIONS
			"d /copycat 775 copycat copycat"  # this will be where our actual system configuration will live in perpetuity
			"Z /copycat 775 copycat copycat"

			# /copycat = our actual nixos build 
			# /static/console/copycat = our current system specific stuff that doesn't need to be saved between machines

		];
#			DO NOT ADD UNLESS YOU'RE ACTIVELY USING SHIT, BE EXPLICIT, BE PURPOSEFUL
#			EXAMPLES: 
#			"d /static/testing 755 drgn users 30s" # 30second hold time for testing - could be some interesting applications to this...
#			"d /static/data 755 drgn users"
#			"d /static/transient 777 drgn users 1d" # conceptually use this for downloading rando source for compliation and testing etc

		#
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


		# SERVICES 
		# We want to backup our last known bootable configuration, that's the perennial directory.
		# We would also like our actual repo to update automatically.
		# I think it's probably a good idea if i actually continue with my current workflow
		# 
		# current workflow is:
		#		edit -> push -> *reinstall
		# 
		# instead i just want to leave it at push and have my whole machine try to automatically 
		# update from git periodically!
		# 
		# we can even have this automatically switch, cozy and comfy that not only if our current 
		# configuration breaks, we have the nixos generations to cover us 
		# and if for some unknown to me at the time of writing reason, that fails, it will be 
		# possible to make it automatically repair itself completely.
		# 
#		systemd.services.copycatSafetyCommit = {
#			wantedBy = [ "multi-user.target" ];
#			after = [ "network.target" ];
#			description = "Hits the git one time with a one time commit. .mew";
#			serviceConfig ={
#				WorkingDirectory = "/copycat" ;
#				Type = "oneshot";
#				path = [ pkgs.git ];
#				ExecStart = "/copycat/bin/safety_on_boot.sh"; 
#				RemainAfterExit = "yes";
#			};
#		};


		# SERVICES

		services.xserver.enable = true;
		services.displayManager.sddm.enable = true;
		services.displayManager.sddm.wayland.enable = true;
		services.desktopManager.plasma6.enable = true; # this is running off unstable currently apparently 
		programs.steam.gamescopeSession.enable = true;
		programs.gamescope.enable = true;

		environment.plasma6.excludePackages = with pkgs.kdePackages; [
			# just in case
		];

		programs.dconf.enable = true;
		# doing gnome theming and shit seems like it might be a pita
		# check https://nixos.wiki/wiki/KDE for more details


		# APPLICATIONS
		# Programs
		programs.zsh.enable = true;
		programs.steam.enable = true;

		powerManagement.powertop.enable = true;


		# Packages
		# When you can add things with programs.PROGRAM - as there seems to be more support with the way it ties in
		environment.systemPackages = with pkgs; [

			# system
			bash
			neovim
			git
			alejandra
			home-manager
			eza
			man
			manix
			gnupg # good write up on sops/pgp: 
			sops  # https://blog.gitguardian.com/a-comprehensive-guide-to-sops/
			age   # while a bit surface level, it's great for brushing up on knowledges
			pinentry
			sshfs
			gimp
			
			# ux
			rust-motd
			firefox
#			ungoogled-chromium
			dunst
			wofi
			foot
			yambar # look into foot and yambar more seriously, seem like great projects.

			# photography stuff
			darktable

			discord
			keepassxc
			librewolf
			spotify
			thunderbird-unwrapped
			floorp
			obsidian
			libsForQt5.ktorrent

			# misc 
			zip
			unzip
			
			# NixOS
			nom
			nh
			
			bat
			nvimpager
			libsForQt5.kcharselect
			libsForQt5.kcalc
			mpv
			whatsapp-for-linux
			ungoogled-chromium
			qemu
			virt-manager
			virt-viewer
			vde2 
			bridge-utils
			netcat-openbsd
			ebtables 
			iptables 
			libguestfs
			dnsmasq
			powertop
			zellij
			fzf
		];
		environment.interactiveShellInit = ''
			alias vim='nvim'
			alias vi='nvim'
			alias nv='nvim'
			alias neovim='nvim'
		'';
		hardware.enableRedistributableFirmware = lib.mkDefault true;
		virtualisation.libvirtd = {
			enable = true;
			qemu = {
				package = pkgs.qemu_kvm;
				runAsRoot = true;
				swtpm.enable = true;
				ovmf = {
				};
			};
		};
		
#		environment.systemPackages = [
#			(import ./scripts/my-test-script.nix { inherit pkgs; })
#		];

		# Configuration
		# Programs
		users.defaultUserShell = pkgs.bash;

#		security.tpm2.enable = true;
#		security.tpm2.pkcs11.enable = true;  # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
#		security.tpm2.tctiEnvironment.enable = true;  # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI env variables

		# USER SETUP
		users.users."drgn" = {
			isNormalUser = true;
			home = "/static/u/drgn"; # make absolutely sure not to have a trailing slash on HOME dirs
			description = "I'm a bad girl, but a good story where I go. I've nothing in my pockets but everything to show.";
			shell = pkgs.zsh;
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

