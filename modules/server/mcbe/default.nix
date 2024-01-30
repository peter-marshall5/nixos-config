{ config, lib, pkgs, ... }:
let
  cfg = config.ab.services.mcbe;
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
  };

  config = lib.mkIf cfg.enable {

    system.activationScripts.mcbe = ''
      mkdir -p ${cfg.dataDir}
    '';

    virtualisation.oci-containers.containers = {
      mcbe = {
        image = "itzg/docker-minecraft-bedrock-server:latest";
        ports = ["localhost:19132:19132"];
        volumes = ["${cfg.dataDir}:/data"];
        cmd = [
          "-e" "EULA=true"
        ];
      };
    };

  };

}
