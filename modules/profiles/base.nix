{ config, lib, pkgs, modulesPath, ... }:

{

  imports = [
    (modulesPath + "/profiles/minimal.nix")
    ./default-user.nix
  ];

  boot.initrd.systemd.enable = true;

  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  boot.initrd.verbose = false;
  boot.kernelParams = [ "quiet" ];

  fileSystems = {
    "/" = {
      label = lib.mkDefault "nixos";
      fsType = "btrfs";
      options = [ "subvol=@" ];
    };
    "/home" = {
      inherit (config.fileSystems."/") device label;
      fsType = "btrfs";
      options = [ "subvol=@home" ];
    };
    "/nix" = {
      inherit (config.fileSystems."/") device label;
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

  services.logrotate.enable = true;

  virtualisation.vmVariant = import ./vm.nix;

  # Reduce build time
  nixpkgs.overlays = [ (final: prev: {
    composefs = prev.composefs.overrideAttrs (old: {
      doCheck = false;
    });
  }) ];

  networking.useNetworkd = true;
  systemd.network.enable = true;

  services.resolved.enable = true;
  services.resolved.extraConfig = ''
    MulticastDNS=true
  '';

  networking.nftables.enable = true;

  # Allow mDNS traffic
  networking.firewall.allowedUDPPorts = [ 5353 ];

  services.openssh = {
    enable = lib.mkDefault true;
    settings.PasswordAuthentication = false;
  };

  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
  '';

  system.stateVersion = "23.05";

}
