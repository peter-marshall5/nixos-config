{ config, lib. pkgs }:

{
boot.kernelPatches = [ {
    name = "linux-surface-config";
    patch = null;
    extraConfig = lib.replaceStrings [ "CONFIG_" "=" ] [ "" " " ] (lib.readFile
      ./surface-6.6.config
    );
  } ] ++ map (pname: {
    name = "linux-surface-${pname}";
    patch = (linuxSurface + "/patches/6.6/${pname}.patch");
  }) [
    "0004-ipts"
    "0005-ithc"
    "0009-surface-typecover"
    "0010-surface-shutdown"
    "0011-surface-gpe"
    "0014-rtc"
  ];
}
