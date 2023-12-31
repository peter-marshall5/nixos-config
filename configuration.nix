# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./ddns.nix
      ./vms.nix
    ];

  system.autoUpgrade = {
    enable = true;
    flake = "github:peter-marshall5/nixos-config";
    flags = [
      "-L" # print build logs
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.systemd.enable = true;

  networking.hostName = "petms"; # Define your hostname.

  networking.useDHCP = lib.mkForce true;

  # Use systemd-networkd for network configuration
  networking.useNetworkd = true;
  systemd.network.enable = true;

  systemd.network = {
    networks."10-lan" = {
      matchConfig.Name = ["ens2" "vm-*"];
      networkConfig = {
        Bridge = "br0";
      };
    };
    networks."10-lan-bridge" = {
      matchConfig.Name = "br0";
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = true;
      };
      linkConfig.RequiredForOnline = "routable";
    };
    netdevs."br0" = {
      netdevConfig = {
        Name = "br0";
        Kind = "bridge";
        MACAddress = "52:54:00:cd:d0:0c";
      };
    };
  };

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  users.users.petms = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILAtjD6VShP3fXpM6Slv458S4Uuhvd/14gnK7oWoRSjK petms@peter-chromebook"];
    shell = pkgs.nushell;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    aria2
    git
    helix
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  age.secrets.duckdns = {
    file = ./secrets/duckdns.age;
  };

  # Enable the DDNS service.
  services.ddns = {
    enable = true;
    interface = "br0";
    domains = [ "petms-opcc" ];
    token = config.age.secrets.duckdns.path;
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}

