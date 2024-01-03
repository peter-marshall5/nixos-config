{ config, lib, pkgs, ... }:
{

  options = {
    networking.bridge.name = lib.mkOption {
      default = "br0";
      type = lib.types.str;
    };
    networking.wan.interfaces = lib.mkOption {
      default = [];
      type = lib.types.listOf lib.types.str;
    };
  };

  config = {

    networking.useDHCP = lib.mkForce true;

    systemd.network = {
      networks."10-lan" = {
        matchConfig.Name = config.networking.wan.interfaces ++ [ "vm-*" ];
        networkConfig = {
          Bridge = config.networking.bridge.name;
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
      netdevs."10-bridge" = {
        netdevConfig = {
          Name = config.networking.bridge.name;
          Kind = "bridge";
        };
      };
    };

  };

}
