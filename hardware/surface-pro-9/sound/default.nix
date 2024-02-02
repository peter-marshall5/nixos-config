{ config, lib, pkgs, ... }: {

  environment.etc = {
    "wireplumber/policy.lua.d/85-surface-policy.lua".source = ./85-surface-policy.lua;
  } // (lib.listToAttrs (map (f: lib.nameValuePair "surface-audio/${f}" {
    source = ./${f};
  }) [
    "graph.json"
    "sp9.wav"
  ]));

}
