{ config, lib, pkgs, modulesPath, ... }:
let
  cfg = config.services.microvms;
in {

  options.services.microvms = {
    enable = lib.mkEnableOption (lib.mdDoc ''
      This option enables the generation of microVM services as defined by `services.microvms.vms`.
    '');
    stateDir = lib.mkOption {
      default = "/var/lib/microvms";
    };
    vms = lib.mkOption {
      default = {};
      type = lib.types.attrsOf lib.types.attrs;
    };
  };

  config = lib.mkIf cfg.enable {

    system.activationScripts.microvms.text = ''
      mkdir ${cfg.stateDir}
    '';

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
          virtualisation.vmVariant.config.virtualisation = {
            memorySize = lib.mkDefault 256;
            cores = lib.mkDefault 1;

            diskSize = lib.mkDefault 2048;

            graphics = false;

            useDefaultFilesystems = false;
            fileSystems = {
              "/" = {
                device = "/dev/vda";
                fsType = "btrfs";
                autoResize = true;
                autoFormat = true;
              };
            };
            diskImage = (cfg.stateDir + "/${name}.img");
            qemu.diskInterface = "virtio";

            qemu.package = pkgs.qemu_test;
            qemu.guestAgent.enable = false;

            qemu.networkingOptions = [
              "-nic tap,mac=${macAddress},ifname=vm-${name},model=virtio,script=no,downscript=no,name=eth0"
            ];
          };
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
