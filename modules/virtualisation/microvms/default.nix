{ config, lib, pkgs, modulesPath, ... }:
let
  cfg = config.services.microvms;
in {

  options.services.microvms = {
    enable = lib.mkEnableOption (lib.mdDoc ''
      This option enables the generation of microVM services as defined by `services.microvms.vms`.
    '');
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
        (modulesPath + "/profiles/qemu-guest.nix")
        (modulesPath + "/profiles/headless.nix")
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
