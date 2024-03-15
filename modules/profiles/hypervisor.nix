{

  systemd.network.netdevs = {
    "10-wan-bridge" = {
      netdevConfig = {
        Name = "br0";
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
    "10-dhcp-server" = {
      name = "lo";
      networkConfig.DHCPServer = true;
      dhcpServerConfig = {
        EmitDNS = false;
        PoolOffset = 10;
        PoolSize = 128;
        EmitRouter = true;
        ServerAddress = "10.0.100.1/24";
      };
    };
    "10-vm-discovery" = {
      name = "vm-*";
      networkConfig = {
        MulticastDNS = true;
        LLMNR = false;
      };
    };
  };

  # Allow DHCP, mDNS and journald traffic from VMs
  networking.firewall.interfaces."lo" = {
    allowedUDPPorts = [ 67 5353 ];
    allowedTCPPorts = [ 19532 ];
  };

  # Forward traffic from VMs
  networking.nat = {
    enable = true;
    internalInterfaces = [ "vm-*" ];
    externalInterface = "br0";
  };

  services.journald.remote = {
    enable = true;
    listen = "http";
    port = 19532;
  };

}
