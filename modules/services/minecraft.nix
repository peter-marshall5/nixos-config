{ config, lib, pkgs, ... }: let
  cfg = config.services.minecraft-bedrock-server;
in {

  options.services.minecraft-bedrock-server = {

    enable = lib.mkEnableOption (lib.mdDoc ''
      If enabled, starts a Minecraft Bedrock Edition server. The server data will be loaded from and saved to `services.minecraft-bedrock-server.dataDir`.
    '');

    eula = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/minecraftbe";
    };

    serverName = lib.mkOption {
      type = lib.types.str;
      default = "mc";
    };

    levelName = lib.mkOption {
      type = lib.types.str;
      default = "mc";
    };

  };

  config = lib.mkIf cfg.enable {

    virtualisation.oci-containers.containers.minecraftbe = {
      image = "itzg/minecraft-bedrock-server:latest";
      ports = ["19132:19132/udp"];
      volumes = ["${toString cfg.dataDir}:/data"];
      environment = {
        EULA = "true";
        SERVER_NAME = cfg.serverName;
        LEVEL_NAME = cfg.levelName;
      };
    };

    systemd.units."podman-minecraftbe".aliases = [ "minecraftbe.service" ];

    assertions = [
      { assertion = cfg.eula;
        message = ''
          You must agree to Minecraft's EULA to run the server.
          Read https://www.minecraft.net/en-us/eula and
          set `services.minecraft-bedrock-server.eula` to `true` if you agree.
        '';
      }
      { assertion = config.virtualisation.oci-containers.backend == "podman"; }
    ];

  };

}
