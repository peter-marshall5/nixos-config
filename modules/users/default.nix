{ config, lib, pkgs, trustedKeys, ... }:

let

  mkUser = u: lib.nameValuePair "${u}" {
    isNormalUser = true;
    createHome = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = trustedKeys;
  };

in

{

  options.ab.users = lib.mkOption {
    default = [];
    type = with lib.types; listOf str;
  };

  config.users.users = builtins.listToAttrs (map mkUser config.ab.users);

}
