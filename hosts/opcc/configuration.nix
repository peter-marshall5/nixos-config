{ config, lib, ... }: {

  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "opcc";
  networking.domain = "opcc.tk";

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

  services.openssh.ports = [ 2200 ];

  services.upnpc.enable = true;

  systemd.network.netdevs = {
    "10-bridge" = {
      netdevConfig = {
        Name = "br0";
        Kind = "bridge";
      };
    };
    "20-nat-bridge" = {
      netdevConfig = {
        Name = "br1";
        Kind = "bridge";
      };
    };
  };

  systemd.network.networks = {
    "10-bridge-uplink" = {
      name = "en*";
      bridge = [ "br0" ];
    };
    "10-bridge-lan" = {
      name = "br0";
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = true;
      };
      dhcpV4Config.VendorClassIdentifier = "Linux";
      linkConfig.RequiredForOnline = "routable";
    };
    "20-bridge-nat" = {
      name = "br1";
      address = [ "fe80::68dd:e8ff:fef5:c932/48" ];
    };
    "20-bridge-vms" = {
      name = "vm-*";
      bridge = [ "br1" ];
      bridgeConfig.Isolated = true;
    };
  };

  services.journald.remote = {
    enable = true;
    listen = "http";
    port = 19532;
  };

}
