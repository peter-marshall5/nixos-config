{ config, lib, pkgs, ... }: {

  imports = [ ../petms/home.nix ];

  home.packages = with pkgs; [
    swaybg
    playerctl
    nerdfonts
    deploy-rs
  ];

  programs.foot = {
    enable = true;
    server.enable = true;
    settings = {
      main = {
        term = "xterm-256color";

        shell = "nu";

        include = "${pkgs.foot.themes}/share/foot/themes/catppuccin";

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
        background = "292e2eff";
        text = "ffffffff";
        selection-text = "ffffffff";
        selection = "282a2bff";
        match = "dfd212ff";
        selection-match = "dfd212ff";
        border = "5ccccdff";
      };
      border = {
        width = 2;
        radius = 3;
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
        modules-right = [ "wireplumber" "mpd" "battery" "clock" ];
        battery = {
          format = "{icon} ";
          format-icons = [ "" "" "" "" "" ];
        };
        mpd = {
          format = "{stateIcon}";
          format-stopped = "󰓛";
          state-icons = {
            paused = "󰐊";
            playing = "󰏤";
          };
        };
        wireplumber = {
          format = "{icon}";
          format-icons = [ "󰕿" "󰖀" "󰕾" ];
          format-muted = "󰖁";
        };
        clock = {
          format = "{:%I:%M %p}";
        };
      };
    };
    style = ''
      * {
        border: none;
        border-radius: 0;
        color: white;
        font-family: DejaVu Nerd Font;
      }
      window {
        background: transparent;
      }
      tooltip {
        background: #292e2e;
      }
      box > * > * {
        padding: 0 6px;
      }
      #workspaces {
        padding: 0;
      }
      #workspaces button {
        padding: 0 4px;
        color: white;
      }
      #clock {
        margin-right: 4px;
      }
    '';
  };

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    settings = import ./config.nix;
  };

  xsession.enable = true;

  services.mako = {
    enable = true;
    textColor = "#ffffff";
    borderColor = "#5CCCCD";
    backgroundColor = "#292E2E";
    borderSize = 2;
    borderRadius = 3;
    width = 400;
    height = 200;
    padding = "20";
    margin = "20";
    defaultTimeout = 15000;
  };

  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      show-failed-attempts = true;
      grace = 2;
      fade-in = 0.4;
      screenshots = true;
      effect-blur = "128x3";
      effect-vignette = "0.9:0.1";
      key-hl-color = "#5ccccd";
      ring-color = "#101313";
      inside-color = "#292e2e";
      text-color = "#ffffff";
    };
  };

  services.swayidle = {
    enable = true;
    events = [{
      event = "before-sleep";
      command = "~/.nix-profile/bin/swaylock -fF --fade-in 0 --grace 0";
    }];
    timeouts = [{
      timeout = 300;
      command = "~/.nix-profile/bin/swaylock -fF";
    } {
      timeout = 360;
      command = "${pkgs.systemd}/bin/systemctl suspend";
    }];
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.numix-cursor-theme;
    name = "Numix-Cursor";
    size = 48;
  };

  fonts.fontconfig.enable = true;

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
