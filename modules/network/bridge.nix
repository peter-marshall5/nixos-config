{ config, lib, ... }:

let

  cfg = config.ab.net.bridge;

  vmTapOpts = { name, ... }: {
    options = {
      macAddress = lib.mkOption {
        default = "";
        type = lib.types.str;
      };
    };
  };

in

{

  options.ab.net.bridge = {
    enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
    };
    name = lib.mkOption {
      default = "br0";
      type = lib.types.str;
    };
    interfaces = lib.mkOption {
      default = [];
      type = lib.types.listOf lib.types.str;
    };
    vmTaps = lib.mkOption {
      default = {};
      type = with lib.types; attrsOf (submodule vmTapOpts);
    };
  };

  config = lib.mkIf cfg.enable {

    networking.useDHCP = lib.mkForce true;

    systemd.network = {
      networks."10-lan" = {
        matchConfig.Name = cfg.interfaces ++ [ "vm-*" ];
        networkConfig = {
          Bridge = cfg.name;
        };
      };
      networks."10-lan-bridge" = {
        matchConfig.Name = "br0";
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = true;
        };
        dhcpV4Config.VendorClassIdentifier = "Linux";
        linkConfig.RequiredForOnline = "routable";
      };
      netdevs."10-bridge" = {
        netdevConfig = {
          Name = cfg.name;
          Kind = "bridge";
        };
      };
    } // lib.mapAttrs' (name: info: lib.nameValuePair "99-vm-${name}" {
      netdevConfig = {
        Kind = "tap";
        Name = "vm-${name}";
        MacAddress = "${info.macAddress}";
      };
    }) cfg.vmTaps;

  };

}
