# /etc/nixos/configuration.nix
{ config, pkgs, ... }:

{
	nix.settings.experimental-features = [ "nix-command" "flakes" ];
	nix.settings.auto-optimise-store = true;

	nix.gc.automatic = true;
	nix.gc.dates = "02:00";
	nix.gc.randomizedDelaySec = "45min";

	#imports = [ ./home.nix ];

	system.stateVersion = "22.05";

	boot.isContainer = true;
	boot.loader.initScript.enable = true;
	boot.cleanTmpDir = true;

	time.timeZone = "Europe/Berlin";

	networking.hostName = "hydra";
	networking.useDHCP = true;
	networking.useNetworkd = true;
	networking.useHostResolvConf = false;
	networking.firewall.enable = false;

	services.resolved = {
		enable = true;
		domains = [ "~." ];
		llmnr = "false";
		dnssec = "false";
		fallbackDns = [];
	};

	services.openssh = {
		enable = true;
		passwordAuthentication = false;
		kbdInteractiveAuthentication = false;
		permitRootLogin = "no";
		ports = [22 22225];
		startWhenNeeded = false;
	};

	systemd.packages = [ pkgs.dbus-broker ];
	systemd.services.dbus-broker.enable = true;
	systemd.services.dbus.enable = false;
	systemd.services.dbus-broker.aliases = [ "dbus.service" ];
	systemd.user.services.dbus-broker.enable = true;
	systemd.user.services.dbus.enable = false;
	systemd.user.services.dbus-broker.aliases = [ "dbus.service" ];

	environment.systemPackages = with pkgs; [
		curl
		nmap
		socat
		tmux
		wget
	];

	programs.neovim = {
		enable = true;
		viAlias = true;
		vimAlias = true;
		defaultEditor = true;
	};

	users.users.strom = {
		isNormalUser = true;
		home = "/home/strom";
		extraGroups = [ "wheel" ];
		openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDXvKUqbSjZpfMWnnmEbHhX7AjdhXHFQe1e4NMemaksl tschubert@bafh.org" ];
	};

	environment.sessionVariables = rec {
		XDG_CACHE_HOME  = "\${HOME}/.cache";
		XDG_CONFIG_HOME = "\${HOME}/.config";
		XDG_BIN_HOME    = "\${HOME}/.local/bin";
		XDG_DATA_HOME   = "\${HOME}/.local/share";

		PATH = [
			"\${XDG_BIN_HOME}"
		];
	};
}
# vi: set ft=nix ts=4 sw=0 sts=-1 sr noet nosi tw=0 fdm=manual: