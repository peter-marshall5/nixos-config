{ config, lib, modulesPath, nixosConfigurations, ... }:
let
  cfg = config.ab;
in {

  config.nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  imports = [
    (modulesPath + "/profiles/headless.nix")
    ./qemu-guest.nix
  ];

  options.ab = {
    host = lib.mkOption {
      default = null;
      type = lib.types.nullOr lib.types.str;
    };
    memory = lib.mkOption {
      default = null;
      type = lib.types.nullOr lib.types.str;
    };
    threads = lib.mkOption {
      default = null;
      type = lib.types.nullOr lib.types.int;
    };
    mac = lib.mkOption {
      default = null;
      type = lib.types.nullOr lib.types.str;
    };
  };

}
