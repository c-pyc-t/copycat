{ pkgs }: 

pkgs.writeShellScriptBin "my-test-script" ''
	echo "hello world" | ${pkgs.cowsay}/bin/cowsay | ${pkgs.lolcat}/bin/lolcat
''
