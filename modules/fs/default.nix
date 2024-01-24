{ config, lib, pkgs, ... }:

let
  cfg = config.ab.fs;
  uuidPath = "/dev/disk/by-uuid/";

  fsOpts = { name, config, ... }: {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        default = if name == "root" then "" else name;
      };
      path = lib.mkOption {
        default = ("/" + (builtins.replaceStrings ["-"] ["/"] config.name));
        type = lib.types.str;
      };
      subvol = lib.mkOption {
        default = ("@" + (builtins.replaceStrings ["-"] ["@"] config.name));
        type = lib.types.str;
      };
      fsType = lib.mkOption {
        type = lib.types.str;
        default = if name == "boot" then "vfat" else "btrfs";
      };
      uuid = lib.mkOption {
        type = lib.types.str;
        default = "";
      };
      device = lib.mkOption {
        type = lib.types.str;
        default = if config.uuid != "" then uuidPath + config.uuid else null;
      };
      luks = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = (config.luks.uuid != "");
        };
        uuid = lib.mkOption {
          type = lib.types.str;
          default = "";
        };
        device = lib.mkOption {
          type = lib.types.str;
          default = if config.luks.uuid != "" then uuidPath + config.luks.uuid else null;
        };
      };
    };
  };

  makeFs = name: fs: lib.nameValuePair "${fs.path}" {
    inherit (fs) device fsType;
    options = lib.mkIf (fs.fsType == "btrfs") [ "subvol=${fs.subvol}" ];
  };

  makeLuks = name: fs: lib.nameValuePair "${name}"  {
    inherit (fs.luks) device;
  };

in
{
  options.ab.fs = {
    enable = lib.mkOption {
      default = true;
      type = lib.types.bool;
    };
    fs = lib.mkOption {
      default = {};
      type = with lib.types; attrsOf (submodule fsOpts);
    };
    boot.lvm.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {

    fileSystems = lib.mapAttrs' makeFs cfg.fs;

    boot.initrd.luks.devices = lib.mapAttrs' makeLuks (lib.filterAttrs (n: fs: fs.luks.enable) cfg.fs);

    boot.initrd.services.lvm.enable = cfg.boot.lvm.enable;

  };
}
