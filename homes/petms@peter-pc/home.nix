{ config, pkgs, ... }: {

  imports = [ ../petms/home.nix ];

  home.packages = with pkgs; [
    swaylock
    swayidle
    swaybg
  ];

  programs.foot = {
    enable = true;
    server.enable = true;
    settings = {
      main = {
        term = "xterm-256color";

        shell = "nu";

        include = "${pkgs.foot.themes}/share/foot/themes/nord";

        font = "Hack:size=13";
        dpi-aware = "no";
      };

      mouse = {
        hide-when-typing = "yes";
      };
    };
  };

  programs.fuzzel = {
    enable = true;
    settings = {
     main = {
        terminal = "${pkgs.foot}/bin/foot";
        layer = "overlay";
        dpi-aware = true;
        horizontal-pad = 40;
        vertical-pad = 20;
        password-character = "•";
        icons-enabled = false;
      };
      colors = {
        background = "141a1bff";
        text = "ffffffff";
        selection-text = "ffffffff";
        selection = "282a2bff";
        match = "dfd212ff";
        selection-match = "dfd212ff";
        border = "16a085ff";
      };
      border = {
        width = 3;
        radius = 0;
      };
    };
  };

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "hyprland/window" ];
        modules-right = [ "mpd" "temperature" ];
      };
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    settings = import ./config.nix;
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.numix-cursor-theme;
    name = "Numix-Cursor";
    size = 48;
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.libsForQt5.breeze-gtk;
      name = "Breeze";
    };

    iconTheme = {
      package = pkgs.gnome.adwaita-icon-theme;
      name = "Adwaita";
    };

    font = {
      name = "Sans";
      size = 11;
    };
  };

  services.mpd.enable = true;
  xdg.userDirs.enable = true;

}
