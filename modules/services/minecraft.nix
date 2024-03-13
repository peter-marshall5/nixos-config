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

    port = lib.mkOption {
      type =lib.types.port;
      default = 19132;
    };

    openFirewall = lib.mkOption {
      default = false;
      type = lib.types.bool;
    };

    memoryLimit = lib.mkOption {
      default = 2048; # Should be enough for most worlds
      type = lib.types.int;
    };

  };

  config = lib.mkIf cfg.enable {

    virtualisation.oci-containers.containers.minecraftbe = {
      image = "itzg/minecraft-bedrock-server:latest";
      ports = ["${toString cfg.port}:19132/udp"];
      volumes = ["${toString cfg.dataDir}:/data"];
      environment = {
        EULA = "true";
        SERVER_NAME = cfg.serverName;
        LEVEL_NAME = cfg.levelName;
      };
      extraOptions = [ "--memory=${toString cfg.memoryLimit}m" ];
    };

    systemd.units."podman-minecraftbe".aliases = [ "minecraftbe.service" ];

    networking.firewall.allowedUDPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    # Options for virtual machines
    virtualisation.vmVariant.config = {
      virtualisation.memorySize = cfg.memoryLimit;

      # Mutable /etc is required by podman
      system.etc.overlay.mutable = true;
      users.mutableUsers = true;
    };

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
