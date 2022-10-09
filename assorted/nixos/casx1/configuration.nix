# /etc/nixos/configuration.nix
{ config, pkgs, ... }:
{
	imports = [
		./hardware-configuration.nix
	];

	boot.cleanTmpDir = true;
	boot.kernelPackages = pkgs.linuxPackages_latest;
	boot.kernelParams = [ "mitigations=off" ];
	hardware.cpu.amd.updateMicrocode = true;

	nix.settings.experimental-features = [ "nix-command" "flakes" ];
	nix.settings.auto-optimise-store = true;

	nix.gc.automatic = true;
	nix.gc.dates = "02:00";
	nix.gc.randomizedDelaySec = "45min";

	system.stateVersion = "22.11";

	security = {
		forcePageTableIsolation = false;
		virtualisation.flushL1DataCache = "never";
	};

	zramSwap = {
		enable = true;
		algorithm = "lz4";
		memoryPercent = 150;

	};

	time.timeZone = "Europe/Berlin";

	networking = {
		hostName = "casx1";
		useNetworkd = true;
		firewall.enable = false;
	};

	services = {
		openssh.enable = true;

		resolved = {
			enable = true;
			domains = [ "~." ];
			llmnr = "false";
			dnssec = "false";
			fallbackDns = [];
		};

	};

	systemd = {
		packages = [ pkgs.dbus-broker ];

		services = {
			dbus.enable = false;
			dbus-broker.enable = true;
			dbus-broker.aliases = [ "dbus.service" ];
		};

		user.services = {
			dbus.enable = false;
			dbus-broker.enable = true;
			dbus-broker.aliases = [ "dbus.service" ];
		};

		network.networks."40-enp1s0" = {
			matchConfig.Name = "enp1s0";

			networkConfig = {
				DHCP = "no";
				DNSSEC = false;
				Domains = [ "~." ];
				IPv6AcceptRA = false;
				IPv6PrivacyExtensions = false;
				LLDP = false;
				LLMNR = false;
			};

			address = [
				"159.69.113.39/32"
				"2a01:4f8:c010:21a8::1/64"
			];

			dns = [
				"185.12.64.1"
				"185.12.64.2"
			];

			ntp = [
				"ntp1.hetzner.de"
				"ntp2.hetzner.de"
				"ntp3.hetzner.de"
			];

			routes = [
			{
				routeConfig = {
					Destination = "172.31.1.1/32";
					Scope = "link";
				};
			}
			{
				routeConfig = {
					Gateway = "172.31.1.1";
					GatewayOnLink = true;
					PreferredSource = "159.69.113.39";
				};
			}
			{
				routeConfig = {
					Gateway = "fe80::1";
					PreferredSource = "2a01:4f8:c010:21a8::1";
				};
			}
			];
		};

	};

	programs.neovim = {
		enable = true;
		viAlias = true;
		vimAlias = true;
		defaultEditor = true;
	};

	environment.systemPackages = with pkgs; [
		curl
		nmap
		socat
		tmux
		wget
	];

	users.users.root.openssh.authorizedKeys.keys = [
		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDXvKUqbSjZpfMWnnmEbHhX7AjdhXHFQe1e4NMemaksl tschubert@bafh.org"
	];

	users.users.strom = {
		isNormalUser = true;
		home = "/home/strom";
		extraGroups = [ "wheel" ];
		openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDXvKUqbSjZpfMWnnmEbHhX7AjdhXHFQe1e4NMemaksl tschubert@bafh.org" ];
	};


	environment.sessionVariables = rec {
		XDG_CACHE_HOME	= "\${HOME}/.cache";
		XDG_CONFIG_HOME = "\${HOME}/.config";
		XDG_BIN_HOME	= "\${HOME}/.local/bin";
		XDG_DATA_HOME	= "\${HOME}/.local/share";

		PATH = [
			"\${XDG_BIN_HOME}"
		];
	};

	virtualisation = {
		podman = {
			enable = true;
			dockerCompat = true;
			dockerSocket.enable = true;
			defaultNetwork.dnsname.enable = true;
		};

		oci-containers.backend = "podman";
	};
}
# vi: set ft=nix ts=4 sw=0 sts=-1 sr noet nosi tw=0 fdm=manual: