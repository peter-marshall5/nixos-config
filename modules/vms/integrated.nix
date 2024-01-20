{ config, lib, pkgs, trustedKeys, ... }:

let

  cfg = config.ab.vms;

  vmOpts = { name, ... }: {
    options = {
      memory = lib.mkOption {
        type = lib.types.str;
      };
      cpus = lib.mkOption {
        type = lib.types.int;
      };
    };
  };

in

{

  options.ab.vms = {
    enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
    };
    vms = lib.mkOption {
      default = {};
      type = with lib.types; attrsOf (submodule vmOpts);
    };
  };

  config = lib.mkIf cfg.enable {

    assertions = [
      { assertion = config.ab.net.bridge.enable; }
    ];

    environment.systemPackages = [ pkgs.cloud-hypervisor ];

    systemd.services = lib.mapAttrs' (name: vm: lib.nameValuePair "vm-${name}" {
      wantedBy = [ "multi-user.target" ];
      script = ''
        ${pkgs.cloud-hypervisor}/bin/cloud-hypervisor --kernel "$kernel" --initramfs "$initrd" --cmdline "$cmdline" \
          --memory size=128M --balloon size="${vm.memory}" \
          --cpus boot="${vm.cpus}" \
          --fs tag=nix-store,socket= \
          --api-socket "/run/vm-${name}.api.sock"
      '';
      preStop = ''
        ${pkgs.cloud-hypervisor}/bin/ch-remote --api-socket "/run/vm-${name}.api.sock" power-button
        sleep 10
      '';
    }) cfg.vms;

  };

}
