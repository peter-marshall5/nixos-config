{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "petms";
  home.homeDirectory = "/home/petms";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    nushell
    helix
    swaybg
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  programs.nushell = {
    enable = true;
    configFile.source = dotfiles/nushell/config.nu;
    envFile.source = dotfiles/nushell/env.nu;
  };

  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      theme = "catppuccin_frappe";
      editor.true-color = true;
    };
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "opcc" = {
        hostname = "svc.opcc.tk";
        port = 2200;
      };
      "petms" = {
        hostname = "svc.opcc.tk";
        port = 2201;
      };
    };
  };

  programs.git = {
    enable = true;
    userEmail = "petms@proton.me";
    userName = "Peter Marshall";
  };

  # home.sessionVariables = {};

  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";
    bind =
      [
        "$mod, Enter, exec, foot"
        "$mod, C, exec, flatpak run com.google.Chrome"
        ", Print, exec, grimblast copy area"
      ] ++ (
        # workspaces
        # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
        builtins.concatLists (builtins.genList (
            x: let
              ws = let
                c = (x + 1) / 10;
              in
                builtins.toString (x + 1 - (c * 10));
            in [
              "$mod, ${ws}, workspace, ${toString (x + 1)}"
              "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
            ]
          )
          10)
      );
    misc = {
      disable_hyprland_logo = true;
      disable_splash_rendering = true;
      vrr = 1;
    };
    decoration = {
      rounding = 2;
      blur = {
        size = 12;
        passes = 2;
        xray = true;
        noise = 0.03;
      };
    };
    exec-once = [
        "waybar"
        #"swaybg -i ~/.wallpaper"
      ];
  };

  programs.waybar.enable = true;
  programs.waybar.settings = {
    mainBar = {
      layer = "top";
      position = "top";
      height = 30;
      modules-left = [ "hyprland/workspaces" ];
      modules-center = [ "hyprland/window" ];
      modules-right = [ "mpd" "temperature" ];
    };
  };

  programs.foot.enable = true;
  programs.foot.server.enable = true;
  programs.foot.settings = {
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

  home.pointerCursor = {
    gtk.enable = true;
    # x11.enable = true;
    package = pkgs.libsForQt5.breeze-gtk;
    name = "Breeze";
    size = 16;
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

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
