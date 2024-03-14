{ lib, pkgs, ... }: {

  imports = [ ./base.nix ];

  networking = {
    useNetworkd = true;
    nftables.enable = true;
  };

  networking.useDHCP = lib.mkForce true;

  systemd.network = let
    bridge = "br0";
  in {
    enable = true;
    networks."10-bridge-uplink" = {
      name = "en*";
      bridge = bridge;
    };
    networks."10-bridge-vms" = {
      name = "vm-*";
      bridge = bridge;
      bridgeConfig.Isolated = true;
    };
    networks."10-bridge-lan" = {
      name = bridge;
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = true;
      };
      dhcpV4Config.VendorClassIdentifier = "Linux";
      linkConfig.RequiredForOnline = "routable";
    };
    netdevs."10-bridge" = {
      netdevConfig = {
        Name = bridge;
        Kind = "bridge";
      };
    };
  };

  services.openssh = {
    enable = lib.mkDefault true;

    settings.PasswordAuthentication = false;
  };

  systemd.watchdog = {
    runtimeTime = "20s";
    rebootTime = "30s";
  };

  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
  '';

  services.journald.remote = {
    enable = true;
    listen = "http";
    port = 19532;
  };

}
