{ config, lib, pkgs, modulesPath, ... }:

{

  imports = [
    (modulesPath + "/profiles/minimal.nix")
    ./autoupgrade
    ./fs
    ./logs
    ./network
    ./sshd
    ./users
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    aria2
    git
    sbctl
    cloudflared
  ];

  security.sudo.wheelNeedsPassword = lib.mkDefault false;

  nix.settings.trusted-users = [ "root" "@wheel" ];

  fonts.fontconfig.enable = lib.mkDefault false;

  sound.enable = lib.mkDefault false;

  environment.noXlibs = lib.mkDefault true;

  documentation.enable = lib.mkDefault false;

  # Allow setting the root password manually.
  users.mutableUsers = lib.mkDefault true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use systemd in the initrd
  boot.initrd.systemd.enable = true;

  # Use the latest kernel
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  # Use systemd-networkd for network configuration
  networking.useNetworkd = true;
  systemd.network.enable = true;

  # Enable nftables-based firewall.
  networking.firewall.enable = true;
  networking.nftables.enable = true;

  # Enable TPM2 support.
  security.tpm2.enable = true;

  # Enable zram swap space.
  zramSwap.enable = true;

  # Enable software raid.
  boot.swraid.enable = true;

  # Enable flake support
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Set your time zone.
  time.timeZone = lib.mkDefault "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
