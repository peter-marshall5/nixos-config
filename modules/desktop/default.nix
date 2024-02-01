{ config, lib, pkgs, ... }:
{

  options.ab.desktop.enable = lib.mkOption {
    default = false;
    type = lib.types.bool;
  };

  config = lib.mkIf config.ab.desktop.enable {

    # Disable boot messages.
    boot.kernelParams = [ "quiet" "loglevel=0" ];

    documentation.enable = true;

    environment.noXlibs = false;

    services.xserver.enable = true;
    # services.xserver.displayManager.sddm.enable = true;

    # services.xserver.desktopManager.plasma5.enable = true;
    # services.xserver.displayManager.defaultSession = "plasmawayland";

    services.greetd.enable = true;
    services.greetd.settings = {
      default_session = {
        command = "${pkgs.greetd.greetd}/bin/agreety --cmd Hyprland";
      };
    };

    services.dbus.enable = true;
    programs.dconf.enable = true;
    xdg.portal = {
      enable = true;
      wlr.enable = true;
      config.common.default = "*";
      extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
    };

    environment.systemPackages = with pkgs; [
      maliit-keyboard
      greetd.greetd
    ];

    fonts.packages = with pkgs; [
      hack-font
    ];

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

    # Disable systemd-network-wait-online
    systemd.network.wait-online.enable = false;

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

    # Enable power management for portable devices.
    ab.powerManagement.enable = true;

    # Use systemd-homed to manage users.
    services.homed.enable = true;

  };

}
