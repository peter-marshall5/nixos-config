{ config, lib, pkgs, ... }:

let
  cfg = config.ab.fs;
  rootDevice = if cfg.lvm.enable then "/dev/vg0/lv0" else "/dev/disk/by-partlabel/nixos";
in
{
  options.ab.fs = {
    enable = lib.mkOption {
      default = true;
      type = lib.types.bool;
    };
    luks.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
    };
    lvm.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable rec {

    fileSystems = {
      "/" = {
        device = if cfg.luks.enable then "/dev/mapper/root" else rootDevice;
        fsType = "btrfs";
        options = [ "subvol=@" ];
      };
      "/home" = {
        device = fileSystems."/".device;
        fsType = "btrfs";
        options = [ "subvol=@home" ];
      };
      "/nix" = {
        device = fileSystems."/".device;
        fsType = "btrfs";
        options = [ "subvol=@nix" ];
      };
    };

    boot.initrd.luks.devices = lib.mkIf cfg.luks.enable {
      root.device = rootDevice;
    };

  };
}
