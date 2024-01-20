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

  mkVmTap = name: info: lib.nameValuePair "99-vm-${name}" {
    netdevConfig = lib.mkMerge [
      {
        Kind = "tap";
        Name = "vm-${name}";
      }
      (lib.mkIf (info.macAddress != "") { MACAddress =  "${info.macAddress}"; })
    ];
  };

in
{

  options.ab.net.bridge.vmTaps = lib.mkOption {
    default = {};
    type = with lib.types; attrsOf (submodule vmTapOpts);
  };

  config.systemd.network.netdevs = lib.mapAttrs' mkVmTap cfg.vmTaps;
}
