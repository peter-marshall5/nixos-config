{ config, lib, pkgs, ... }:
let
  cfg = config.services.microvms;
in {

  options.services.microvms = {
    enable = lib.mkOption {
      default = true;
      type = lib.types.bool;
    };
    vms = lib.mkOption {
      default = {};
      type = lib.types.attrsOf lib.types.attrs;
    };
  };

  config = lib.mkIf cfg.enable {

    system.build.microvms = lib.mapAttrs (name: { type ? name, config, macAddress }: lib.nixosSystem {
      inherit (pkgs.hostPlatform) system;
      modules = [
        ../..
        ../../../modules/profiles/headless-qemu-vm.nix
        ./services/${type}
        {
          svc = config; # Abstracted config options for services
          networking.hostName = lib.mkDefault name;
          networking.interfaces.eth0.macAddress = macAddress;
        }
      ];
    }) cfg.vms;

    systemd.services = lib.mapAttrs' (name: { config, ... }: lib.nameValuePair "microvm-${name}" {
      wantedBy = [ "multi-user.target" ];
      restartIfChanged = false;
      script = (config.system.build.vm + "/bin/${config.system.build.vm.meta.mainProgram}");
    }) config.system.build.microvms;

  };

}
