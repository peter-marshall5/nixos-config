{ config, lib, ... }:
{

  options.ab.autoUpgrade = lib.mkOption {
    default = true;
    type = lib.types.bool;
  };

  config.system.autoUpgrade = lib.mkIf config.ab.autoUpgrade {
    enable = true;
    flake = "github:peter-marshall5/nixos-config";
    flags = [
      "-L" # print build logs
      "--refresh" # always use latest version
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
  };

}
