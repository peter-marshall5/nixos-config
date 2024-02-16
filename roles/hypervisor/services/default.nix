{ config, lib, pkgs, agenix, ... }:
let

  cfg = config.ab.services;

  commonOpts = {
    options.svc = {
      memory = lib.mkOption {
        default = "256M";
        type = lib.types.str;
      };
      storage = lib.mkOption {
        default = "8G";
        type = lib.types.str;
      };
      threads = lib.mkOption {
        default = 1;
        type = lib.types.int;
      };
    };
  };

  mkService = name: { type ? name, config }: rec {
    system = lib.nixosSystem {
      inherit (pkgs.hostPlatform) system;
      modules = [
        agenix.nixosModules.default
        commonOpts
        ../../../common/network/upnp
        ../../../services/${type}
        ./vm-base.nix
        {
          svc = config; # Abstracted config options for services
          networking.hostName = lib.mkDefault name;
        }
      ];
    };
    runner = pkgs.callPackage ./runner.nix {
      inherit name;
      inherit (system.config.svc) memory storage threads;
      stateImage = "${cfg.stateDir}/${name}.img";
      nixStoreImage = "${system.config.system.build.image}/image.raw";
      linux = "${system.config.boot.kernelPackages.kernel}/${system.config.system.boot.loader.kernelFile}";
      initrd = "${system.config.system.build.initialRamdisk}/${system.config.system.boot.loader.initrdFile}";
      cmdline = "init=${system.config.system.build.toplevel}/init ${toString system.config.boot.kernelParams}";
    };
  };

  mkServiceUnit = name: service: lib.nameValuePair "service-${name}" {
    wantedBy = [ "multi-user.target" ];
    restartIfChanged = false;
    serviceConfig.ExecStart = service.runner;
  };

in {

  options.ab.services = {
    vms = lib.mkOption {
      default = [];
      type = lib.types.attrsOf lib.types.attrs;
    };
    hypervisor = lib.mkOption {
      default = "qemu";
      type = lib.types.str;
    };
    stateDir = lib.mkOption {
      default = "/var/lib/svc";
      type = lib.types.path;
    };
  };

  config = {

    system.activationScripts.service-vm-host = ''
      mkdir -p ${cfg.stateDir}
    '';

    system.build.services = lib.mapAttrs mkService cfg.vms;

    systemd.services = lib.mapAttrs' mkServiceUnit config.system.build.services;

  };

}
