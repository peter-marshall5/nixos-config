{ config, lib, pkgs, agenix, ... }:
let

  cfg = config.ab.services;

  tinyQemu = pkgs.qemu_kvm.override {
    nixosTestRunner = true;
    guestAgentSupport = false;
    libiscsiSupport = false;
    capstoneSupport = false;
    hostCpuOnly = true;
  };

  commonConfig = { config, lib, pkgs, ... }: {
    options.svc = {
      hostName = lib.mkOption {
        type = lib.types.str;
      };
    };
  };

  mkService = name: { type ? name, config }:
  let
    system = lib.nixosSystem {
      inherit (pkgs.hostPlatform) system;
      modules = [
        agenix.nixosModules.default
        ../../common
        ../../services/${type}
        {
          svc = config; # Abstracted config options for services
        }
      ];
    };
    image = system.config.system.build.toplevel;
  in lib.nameValuePair "service-${name}" {
    wantedBy = [ "multi-user.target" ];
    restartIfChanged = false;
    scriptArgs = "%i";
    script = (''
      qemu ${image}
    '');
  };

in {

  options.ab.services = lib.mkOption {
    default = [];
    type = lib.types.attrsOf lib.types.attrs;
  };

  config.systemd.services = lib.mapAttrs' mkService cfg;

}
