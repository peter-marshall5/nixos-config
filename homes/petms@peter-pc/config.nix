{
  "$mod" = "SUPER";
  bind =
    [
      "$mod, Return, exec, foot"
      "$mod, C, exec, flatpak run com.google.Chrome"
      ", Print, exec, grimblast copy area"
      "$mod, Q, killactive,"
      "$mod, F, fullscreen,"
      "$mod, Space, togglefloating,"
      "SUPER SHIFT, left, movewindow, l"
      "SUPER SHIFT, right, movewindow, r"
      "SUPER SHIFT, up, movewindow, u"
      "SUPER SHIFT, down, movewindow, d"
      "CTRL ALT, L, exec, swaylock"
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
  bindr = [ "SUPER, SUPER_L, exec, pkill fuzzel || fuzzel" ];
  binde = [
      ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
      ", XF86AudioLowerVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-"
      ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ", XF86AudioPause, exec, playerctl play-pause"
      ", XF86AudioPlay, exec, playerctl play-pause"
      ", XF86MonBrightnessUp, exec, brillo -A 2 -u 100000 -q"
      ", XF86MonBrightnessDown, exec, brillo -U 2 -u 100000 -q"
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
    rounding = 3;
    blur = {
      size = 32;
      passes = 4;
      xray = true;
      noise = 0.2;
    };
  };
  general = {
    gaps_in = 2;
    gaps_out = 5;
    border_size = 2;
    "col.active_border" = "0xff61BCBD";
  };
  exec-once = [
      "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      "waybar"
      "swaybg -i ~/.wallpaper"
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
