{ config, lib, pkgs, ... }:
{

  options.ab.desktop.enable = lib.mkOption {
    default = false;
    type = lib.types.bool;
  };

  config = lib.mkIf config.ab.desktop.enable {

    boot.kernelParams = [
      "quiet" "loglevel=0" # Disable boot messages
      "workqueue.power_efficient=1" # Improve scheduling power efficiency
    ];

    documentation.enable = true;

    environment.noXlibs = false;

    services.xserver.enable = true;
    services.xserver.displayManager.sddm.enable = true;
    services.xserver.desktopManager.plasma5.enable = true;

    services.xserver.displayManager.defaultSession = "plasmawayland";

    environment.systemPackages = [ pkgs.maliit-keyboard ];

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
      pulse.enable = true;
    };

    # Enable console font configration.
    fonts.fontconfig.enable = true;

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
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 30;
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      CPU_HWP_DYN_BOOST_ON_AC = 1;
      CPU_HWP_DYN_BOOST_ON_BAT = 0;
    };

    # Use systemd-homed to manage users.
    services.homed.enable = true;

  };

}
