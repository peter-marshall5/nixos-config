{ config, lib, pkgs, ... }:
{

  imports = [ ./fs.nix ];

  options.ab = {

    autoUpgrade = lib.mkOption {
      default = true;
      type = lib.types.bool;
    };

  };

  config = {

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      wget
      aria2
      git
      helix
    ];

    # Automatically pull updates from the flake repo during off hours
    system.autoUpgrade = lib.mkIf config.ab.autoUpgrade {
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

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It's perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "23.05"; # Did you read the comment?

  };

}
