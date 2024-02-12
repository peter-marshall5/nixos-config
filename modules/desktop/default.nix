{ config, lib, pkgs, ... }:
{

  options.ab.desktop = {
    enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
    };
    autologin = {
      enable = lib.mkOption {
        default = (config.ab.desktop.autologin.user != "");
        type = lib.types.bool;
      };
      user = lib.mkOption {
        default = "";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf config.ab.desktop.enable {

    # Disable boot messages.
    boot.kernelParams = [ "quiet" ];
    boot.consoleLogLevel = 0;

    documentation.enable = true;

    environment.noXlibs = false;

    services.xserver.enable = true;

    services.greetd.enable = true;
    services.greetd.settings = {
      initial_session = lib.mkIf config.ab.desktop.autologin.enable {
        command = "Hyprland";
        user = config.ab.desktop.autologin.user;
      };
      default_session = {
        command = "${pkgs.greetd.greetd}/bin/agreety --cmd Hyprland";
      };
    };

    services.dbus.enable = true;
    programs.dconf.enable = true;
    xdg.portal = {
      enable = true;
      config.common.default = "*";
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
    };

    environment.systemPackages = with pkgs; [
      maliit-keyboard
      pavucontrol
    ];

    fonts.packages = with pkgs; [
      hack-font
    ];

    security.pam.services.swaylock = {};

    hardware.brillo.enable = true;

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
    ab.ssh.enable = false;

    # Open some commonly used safe ports.
    networking.firewall = {
      allowedTCPPorts = [ 8080 ];
      allowedUDPPorts = [ 1900 ];
    };

    # Enable power management for portable devices.
    ab.powerManagement.enable = true;

  };

}
