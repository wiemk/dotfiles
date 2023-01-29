{
	imports = [ <home-manager/nixos> ];

	home-manager.useGlobalPkgs = true;
	home-manager.useUserPackages = true;

	home-manager.users.strom = { pkgs, ... }: {
		home.packages = with pkgs; [
			glow
			httpie
			git
			neovim

		];
		programs.bash.enable = true;
	};

	nixpkgs.overlays = [
		(import (builtins.fetchTarball {
				 url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
				 }))
	];
}