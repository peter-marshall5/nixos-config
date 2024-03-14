{ config, lib, pkgs, ... }: {

  imports = [
    ./hardware-configuration.nix
    ../../modules/profiles/hypervisor.nix
  ];

  networking.hostName = "opcc";
  networking.domain = "opcc.tk";

  environment.systemPackages = with pkgs; [
    tcpdump
  ];

  services.duckdns.enable = true;

  age.secrets.duckdns.file = ../../secrets/duckdns.age;
  services.duckdns.tokenFile = config.age.secrets.duckdns.path;

  # age.secrets.cloudflare.file = ../../../secrets/cloudflare.age;
  # services.cloudflare-dyndns = {
  #   enable = true;
  #   ipv4 = true;
  #   domains = config.networking.domain;
  #   apiTokenFile = config.age.secrets.cloudflare.path;
  # };

  security.sudo.wheelNeedsPassword = false;

  services.openssh.ports = [ 2200 ];

  services.upnpc.enable = true;

  networking.nat.forwardPorts = [
    {
      sourcePort = 19134;
      proto = "udp";
      destination = "[fe80::848f:b3ff:fe38:dca3%br1]:19132"; # Cheesecraft
    }
    {
      sourcePort = 19135;
      proto = "udp";
      destination = "[fe80::b82a:b8ff:feb5:e371%br1]:19132"; # Build Battle
    }
  ];

  networking.firewall = {
    allowedUDPPorts = [ 19134 19135 ];
  };

}
