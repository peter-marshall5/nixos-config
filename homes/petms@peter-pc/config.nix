{
  "$mod" = "SUPER";
  bind =
    [
      "$mod, Return, exec, foot"
      "$mod, D, exec, fuzzel"
      "$mod, C, exec, flatpak run com.google.Chrome"
      ", Print, exec, grimblast copy area"
      "$mod, Q, killactive,"
      "$mod, F, fullscreen,"
      "$mod, Space, togglefloating,"
      "SUPER SHIFT, left, movewindow, l"
      "SUPER SHIFT, right, movewindow, r"
      "SUPER SHIFT, up, movewindow, u"
      "SUPER SHIFT, down, movewindow, d"
      "CTRL ALT, L, exec, swaylockd"
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
  bindl = [
      ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
      ", XF86AudioLowerVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-"
    ];
  bindm = [
    "SUPER, mouse:272, movewindow"
    "SUPER, mouse:273, resizewindow"
  ];
  misc = {
    disable_hyprland_logo = true;
    disable_splash_rendering = true;
    vrr = 0;
  };
  decoration = {
    rounding = 0;
    blur = {
      size = 12;
      passes = 2;
      xray = true;
      noise = 0.03;
    };
  };
  general = {
    gaps_in = 2;
    gaps_out = 5;
  };
  exec-once = [
      "waybar"
      #"swaybg -i ~/.wallpaper"
    ];
  monitor = [
    "eDP-1,2880x1920@120,0x0,1.875"
  ];
  input.touchpad = {
    natural_scroll = true;
    scroll_factor = 0.7;
  };
  dwindle = {
    no_gaps_when_only = 1;
  };
  animation = [
      "workspaces,1,3,default,slidefade 10%"
      "windows,1,4,default,popin"
      "fade,1,4,default"
    ];
}
