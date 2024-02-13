{ config, lib, pkgs, ... }:
let

  cfg = config.ab.services.mcbe;

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

  ports = map (v: v.port) (builtins.attrValues cfg.servers);

in
{

  options.ab.services.mcbe = {

    enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
    };

    dataDir = lib.mkOption {
      default = "/var/lib/mcbe";
      type = lib.types.str;
    };

    servers = lib.mkOption {
      default = {};
      type = lib.types.attrsOf (lib.types.submodule serverOpts);
    };

    upnp.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };

  };

  config = lib.mkIf cfg.enable {

    system.activationScripts.mcbe = let
      dataDirs = lib.mapAttrsToList (n: v: (v.dataDir)) cfg.servers;
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
    }) cfg.servers;

    networking.firewall.allowedUDPPorts = ports;

    ab.net.upnp = lib.mkIf cfg.upnp.enable {
      enable = true;
      openUDPPorts = ports;
    };

  };

}
