{ config, lib, pkgs, ... }:
{

  options.ab.desktop.enable = lib.mkOption {
    default = false;
    type = lib.types.bool;
  };

  config = lib.mkIf config.ab.desktop.enable {

    # Disable boot messages.
    boot.kernelParams = [ "quiet" "loglevel=1" ];

    documentation.enable = true;

    environment.noXlibs = false;

    services.xserver.enable = true;
    services.xserver.displayManager.sddm.enable = true;
    services.xserver.desktopManager.plasma5.enable = true;

    services.xserver.displayManager.defaultSession = "plasmawayland";

    services.flatpak.enable = true;

    security.sudo.wheelNeedsPassword = true;

    # Enable networking
    ab.net.networkmanager.enable = true;

    # Enable bluetooth
    hardware.bluetooth.enable = true;

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Enable avahi for network discovery.
    services.avahi = {
      enable = true;
      nssmdns4 = true;
    };

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

    # Enable console font configration.
    fonts.fontconfig.enable = true;

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # SSH can be a security hole on desktop systems.
    services.openssh.enable = false;

    services.power-profiles-daemon.enable = false;

    services.tlp.enable = true;
    services.tlp.settings = {
      PCIE_ASPM_ON_BAT = "powersupersave";
      SOUND_POWER_SAVE_CONTROLLER = false;
      PLATFORM_PROFILE_ON_AC = "balanced";
      PLATFORM_PROFILE_ON_BAT = "low-power";
      RUNTIME_PM_ON_AC = "auto";
      RUNTIME_PM_ON_BAT = "auto";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
    };

    # Use systemd-homed to manage users.
    services.homed.enable = true;

  };

}
