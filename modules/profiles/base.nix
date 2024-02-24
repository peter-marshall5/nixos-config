{ config, lib, pkgs, modulesPath, ... }:

{

  imports = [
    (modulesPath + "/profiles/minimal.nix")
  ];

  boot.initrd.systemd.enable = true;

  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  fileSystems = {
    "/" = {
      label = "nixos";
      fsType = "btrfs";
      options = [ "subvol=@" ];
    };
    "/home" = {
      device = "/";
      fsType = "btrfs";
      options = [ "subvol=@home" ];
    };
    "/nix" = {
      device = "/";
      fsType = "btrfs";
      options = [ "subvol=@nix" ];
    };
  };
  
  system.autoUpgrade = {
    flake = "github:peter-marshall5/nixos-config";
    flags = [
      "-L" # print build logs
      "--refresh" # always use latest version
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  i18n.defaultLocale = "en_US.UTF-8";

  system.stateVersion = "23.05";

}
