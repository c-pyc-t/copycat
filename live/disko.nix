# disko.nix designed for copycat
# @niceguy

{
  device ? throw "Set this to your disk device, e.g. /dev/sda",
  ...
}: {
  disko.devices = {
		disk.main = {
			inherit device;
			type = "disk";
			content = {
				type = "gpt";
				partitions = {
          boot = {
            name = "boot";
            size = "1M";
            type = "EF02";
          };
					esp = {
						name = "esp";
						size = "1024M";
						type = "EF00";
						content = {
							type = "filesystem";
							format = "vfat";
							mountpoint = "/boot";
							mountOptions = [
								"defaults"
							];
						};
					};
					luks = {
						size = "100%";
						content = {
							type = "luks";
							name = "copycat";
							settings = {
								allowDiscards = true;
							};
							content = {
								type = "lvm_pv";
								vg = "copycat";
							};
						};
					};
				};
			};
		};
		lvm_vg = {
			copycat = {
				type = "lvm_vg";
				lvs = {
					swap = {
						size = "32GiB";
						content = {
							type = "swap";
							resumeDevice = true;
						};
					};
					root = {
						size = "100%FREE";
						content = {
							type = "btrfs";
							extraArgs = [ "-f" ];

							subvolumes = {
								"/root" = {
									mountpoint = "/";
								};
								"/copycat" = {
									mountOptions = [ "subvol=persist" "noatime" ];
									mountpoint = "/copycat";
								};
								"/static" = {
									mountOptions = [ "subvol=persist" "noatime" ];
									mountpoint = "/static";
								};
								"/nix" = {
									mountOptions = [ "subvol=nix" "noatime" ];
									mountpoint = "/nix";
								};
							};
						};
					};
				};
			};
		};
	};
}
