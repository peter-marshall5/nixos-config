{ config, lib, pkgs, ... }:
{

  options.ab.desktop.enable = lib.mkOption {
    default = false;
    type = lib.types.bool;
  };

  config = lib.mkIf config.ab.desktop.enable {

    # Disable boot messages.
    boot.kernelParams = [ "quiet" "loglevel=1" ];

    services.xserver.enable = true;
    services.xserver.displayManager.sddm.enable = true;
    services.xserver.desktopManager.plasma5.enable = true;

    services.xserver.displayManager.defaultSession = "plasmawayland";

    services.flatpak.enable = true;

    # Enable networking
    ab.net.networkmanager.enable = true;

    # Enable bluetooth
    hardware.bluetooth.enable = true;

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Enable sound with pipewire.
    sound.enable = true;
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

  };

}