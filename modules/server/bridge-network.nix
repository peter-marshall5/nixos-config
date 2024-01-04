{ config, lib, pkgs, ... }:
{

  options = {
    ab.bridge.name = lib.mkOption {
      default = "br0";
      type = lib.types.str;
    };
    ab.wan.interfaces = lib.mkOption {
      default = [];
      type = lib.types.listOf lib.types.str;
    };
  };

  config = {

    networking.useDHCP = lib.mkForce true;

    systemd.network = {
      networks."10-lan" = {
        matchConfig.Name = config.ab.wan.interfaces ++ [ "vm-*" ];
        networkConfig = {
          Bridge = config.ab.bridge.name;
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
          Name = config.ab.bridge.name;
          Kind = "bridge";
        };
      };
    };

  };

}
