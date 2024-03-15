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

  # Domains are not supported yet in networking.nat.forwardPorts
  networking.nftables.ruleset = ''
    table ip nat {
      chain pre {
        type nat hook prerouting priority dstnat; policy accept;
        iifname "br1" tcp dport 19134 dnat to cheesecraft.local:19132;
        iifname "br1" tcp dport 19134 dnat to build-battle.local:19132
      }
    }
  '';

  networking.firewall = {
    allowedUDPPorts = [ 19134 19135 ];
  };

}
