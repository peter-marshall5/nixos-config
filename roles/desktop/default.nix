{ config, lib, pkgs, ... }:
{

  options.ab.desktop = {
    autologin = {
      enable = lib.mkOption {
        default = config.ab.fs.luks.enable;
        type = lib.types.bool;
      };
      user = lib.mkOption {
        default = lib.lists.take 1 config.ab.users;
        type = lib.types.nullOr lib.types.str;
      };
    };
  };

  config = {

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
    ab.ssh.enable = lib.mkDefault false;

    # Open some commonly used safe ports.
    networking.firewall = {
      allowedTCPPorts = [ 8080 ];
      allowedUDPPorts = [ 1900 5353 ];
      allowedUDPPortRanges = [{ from = 32768; to = 61000; }];
    };

    # Make firewall debugging easier.
    networking.firewall.rejectPackets = true;

    # Enable power management for portable devices.
    ab.powerManagement.enable = true;

    # Enable secure boot.
    ab.secureboot.enable = lib.mkDefault true;

    # Enable disk encryption.
    ab.fs.luks.enable = lib.mkDefault true;

    # Use LVM for easier partition management.
    ab.fs.lvm.enable = lib.mkDefault true;

  };

}
