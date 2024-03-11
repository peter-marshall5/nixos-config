
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

      dataDir = lib.mkOption {
        default = (cfg.dataDir + "/" + name);
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

in
{

  options.svc = {

    dataDir = lib.mkOption {
      default = "/var/lib/mcbe";
      type = lib.types.str;
    };

    worlds = lib.mkOption {
      default = {};
      type = lib.types.attrsOf (lib.types.submodule serverOpts);
    };

  };

  config = {

    system.activationScripts.mcbe = let
      dataDirs = lib.mapAttrsToList (n: v: (v.dataDir)) cfg.worlds;
    in ''
      mkdir -p ${toString dataDirs}
    '';

    virtualisation.oci-containers.containers = lib.mapAttrs (n: v: {
      image = "itzg/minecraft-bedrock-server:latest";
      ports = ["${toString v.port}:19132/udp"];
      volumes = ["${v.dataDir}:/data"];
      environment = {
        EULA = "true";
        SERVER_NAME = v.title;
        LEVEL_NAME = v.levelName;
      } // v.extraOpts;
    }) cfg.worlds;

    networking.firewall.allowedUDPPorts = map (v: v.port) (builtins.attrValues cfg.worlds);

    services.upnpc.enable = true;

    system.stateVersion = "24.05";

  };

}
