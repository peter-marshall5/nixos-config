{ config, lib, pkgs, ... }:

let

  cfg = config.ab.logs;

in {

  options.ab.logs = {
    notify.enable = lib.mkOption {
      default = true;
      type = lib.types.bool;
    };
    notify.services = lib.mkOption {
      default = [];
      type = with lib.types; listOf str;
    };
  };

  config.systemd.services = lib.mkIf cfg.notify.enable ({
    "notify-problems@" = {
      enable = true;
      environment.SERVICE = "%i";
      script = ''
        echo "$SERVICE FAILED!"
      '';
    };
  } // builtins.listToAttrs (map (name: lib.nameValuePair name {
    unitConfig.OnFailure = "notify-problems@%i.service";
  }) cfg.notify.services));

}
