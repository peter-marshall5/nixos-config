
{ config, lib, pkgs, ... }:
let

  cfg = config.svc;

  serverOpts = { name, ... }: {
    options = {

      port = lib.mkOption {
        type = lib.types.int;
      };

      name = lib.mkOption {
        default = name;
        type = lib.types.str;
      };

      title = lib.mkOption {
        default = name;
        type = lib.types.str;
      };

      levelName = lib.mkOption {
        default = name;
        type = lib.types.str;
      };

      extraOpts = lib.mkOption {
        default = {};
        type = lib.types.attrsOf lib.types.str;
      };

    };
  };


  dataDir = "/var/lib/mcbe";

in
{

  options.svc = {

    worlds = lib.mkOption {
      default = {};
      type = lib.types.attrsOf (lib.types.submodule serverOpts);
    };

  };

  config = {

    system.activationScripts.mcbe = let
      worldDirs = lib.mapAttrsToList (n: v: (dataDir + "/" + v.name)) cfg.worlds;
    in ''
      mkdir -p /var/lib
      ${pkgs.btrfs-progs}/bin/btrfs subvolume create ${toString dataDir}
      mkdir ${toString worldDirs}
    '';

    virtualisation.oci-containers.containers = lib.mapAttrs (n: v: {
      image = "itzg/minecraft-bedrock-server:latest";
      ports = ["${toString v.port}:19132/udp"];
      volumes = ["${dataDir + "/" + v.name}:/data"];
      environment = {
        EULA = "true";
        SERVER_NAME = v.title;
        LEVEL_NAME = v.levelName;
      } // v.extraOpts;
    }) cfg.worlds;

    networking.firewall.allowedUDPPorts = map (v: v.port) (builtins.attrValues cfg.worlds);

  };

}
