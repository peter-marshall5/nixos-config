{ config, lib, pkgs, ... }:

let
  cfg = config.ab.fs;
  uuidPath = "/dev/disk/by-uuid/";
in
{
  options.ab.fs = {
    enable = lib.mkOption {
      default = true;
      type = lib.types.bool;
    };
    root.type = lib.mkOption {
      default = "btrfs";
      type = lib.types.str;
    };
    root.uuid = lib.mkOption {
      type = lib.types.str;
    };
    home.type = lib.mkOption {
      default = "btrfs";
      type = lib.types.str;
    };
    home.uuid = lib.mkOption {
      default = "";
      type = lib.types.str;
    };
    home.luksUuid = lib.mkOption {
      default = "";
      type = lib.types.str;
    };
    esp.uuid = lib.mkOption {
      type = lib.types.str;
    };
    esp.type = lib.mkOption {
      default = "vfat";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    fileSystems."/" =
      { device = (uuidPath + cfg.root.uuid);
        fsType = cfg.root.type;
        options = [ "subvol=@" ];
      };

    fileSystems."/nix" =
      { device = (uuidPath + cfg.root.uuid);
        fsType = cfg.root.type;
        options = [ "subvol=@nix" ];
      };

    fileSystems."/home" =
      { device = (uuidPath + cfg.home.uuid);
        fsType = "btrfs";
      };

    boot.initrd.luks.devices."home".device = lib.mkIf (cfg.home.luksUuid != "") (uuidPath + cfg.home.luksUuid);

    fileSystems."/boot" =
      { device = (uuidPath + cfg.esp.uuid);
        fsType = cfg.esp.type;
      };
    };
}
