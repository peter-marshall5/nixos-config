{

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

  # Allow DHCP, mDNS and journald traffic on internal bridge
  networking.firewall.interfaces."br1" = {
    allowedUDPPorts = [ 67 5353 ];
    allowedTCPPorts = [ 19532 ];
  };

  # Forward traffic from VMs
  networking.nat = {
    enable = true;
    internalInterfaces = [ "br1" ];
    internalIPs = [ "10.0.100.0/24" ];
    externalInterface = "br0";
  };

  services.journald.remote = {
    enable = true;
    listen = "http";
    port = 19532;
  };

}
