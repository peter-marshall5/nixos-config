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
    root.luksUuid = lib.mkOption {
      default = "";
      type = lib.types.str;
    };
    nixStoreSubvol = lib.mkOption {
      default = true;
      type = lib.types.bool;
    };
    home.type = lib.mkOption {
      default = "btrfs";
      type = lib.types.str;
    };
    home.uuid = lib.mkOption {
      default = cfg.root.uuid;
      type = lib.types.str;
    };
    home.luksUuid = lib.mkOption {
      default = cfg.root.luksUuid;
      type = lib.types.str;
    };
    home.onRoot = lib.mkOption {
      default = (cfg.root.uuid == cfg.home.uuid);
      type = lib.types.bool;
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

    boot.initrd.luks.devices."root" = lib.mkIf (cfg.root.luksUuid != "")
      { device = (uuidPath + cfg.root.luksUuid); };

    fileSystems."/nix" = lib.mkIf cfg.nixStoreSubvol
      { device = (uuidPath + cfg.root.uuid);
        fsType = cfg.root.type;
        options = [ "subvol=@nix" ];
      };

    fileSystems."/home" = lib.mkIf (cfg.home.uuid != "")
      { device = (uuidPath + cfg.home.uuid);
        fsType = "btrfs";
        options = lib.mkIf cfg.home.onRoot [ "subvol=@home" ];
      };

    boot.initrd.luks.devices."home" = lib.mkIf (cfg.home.luksUuid != "")
      { device = (uuidPath + cfg.home.luksUuid); };

    fileSystems."/boot" =
      { device = (uuidPath + cfg.esp.uuid);
        fsType = cfg.esp.type;
      };
    };

}
