{ config, lib, pkgs, ... }:

let

  mkUser = u: lib.nameValuePair "${u}" {
    isNormalUser = true;
    createHome = true;
    shell = pkgs.nushell;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = import ../../ssh-keys.nix "";
  };

in

{

  options.ab.users = lib.mkOption {
    default = [];
    type = with lib.types; listOf str;
  };

  config.users.users = builtins.listToAttrs (map mkUser config.ab.users);

}
