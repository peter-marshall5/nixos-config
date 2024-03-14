{ config, lib, pkgs, ... }: {

  imports = [
    ./hardware-configuration.nix
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
      address = [ "10.0.100.2/24" ];
      networkConfig = {
        DHCPServer = true;
        MulticastDNS = true;
        LLMNR = false;
      };
      dhcpServerConfig = {
        EmitDNS = false;
        PoolOffset = 10;
        PoolSize = 128;
        ServerAddress = "10.0.100.1/24";
        EmitRouter = true;
      };
      bridgeConfig.Isolated = false;
    };
    "20-bridge-vms" = {
      name = "vm-*";
      bridge = [ "br1" ];
      bridgeConfig.Isolated = true;
    };
  };

  # Allow DHCP and journald traffic
  networking.firewall.allowedUDPPorts = [ 67 19532 ];

  # Forward traffic from VMs
  networking.nat = {
    enable = true;
    internalInterfaces = [ "br1" ];
    externalInterface = "br0";
  };

  services.journald.remote = {
    enable = true;
    listen = "http";
    port = 19532;
  };

}
