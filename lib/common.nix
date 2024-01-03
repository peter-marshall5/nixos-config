{ config, lib, pkgs, ... }:
{

  # Automatically pull updates from the flake repo during off hours
  system.autoUpgrade = {
    enable = true;
    flake = "github:peter-marshall5/nixos-config";
    flags = [
      "-L" # print build logs
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use systemd in the initrd  
  boot.initrd.systemd.enable = true;

  # Use systemd-networkd for network configuration
  networking.useNetworkd = true;
  systemd.network.enable = true;

  # Enable flake support
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

}
