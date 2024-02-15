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

  mkService = name: { type ? name, config }:
  let
    system = lib.nixosSystem {
      inherit (pkgs.hostPlatform) system;
      modules = [
        agenix.nixosModules.default
        commonOpts
        ../../../common
        ../../../services/${type}
        ./vm-base.nix
        {
          svc = config; # Abstracted config options for services
          networking.hostName = lib.mkDefault name;
        }
      ];
    };
    rootfs = system.config.system.build.image;
    linux = "${system.config.boot.kernelPackages.kernel}/${system.config.system.boot.loader.kernelFile}";
    initrd = "${system.config.system.build.initialRamdisk}/${system.config.system.boot.loader.initrdFile}";
    cmdline = "init=${system.config.system.build.toplevel}/init ${toString system.config.boot.kernelParams}";
    state = "${cfg.stateDir}/${name}.img";
    memory = system.config.svc.memory;
    storage = system.config.svc.storage;
    threads = system.config.svc.threads;
  in lib.nameValuePair "service-${name}" {
    wantedBy = [ "multi-user.target" ];
    restartIfChanged = false;
    script = (''
      if ! [ -e "${state}" ]; then
        touch "${storage}"
        ${pkgs.e2fsprogs}/bin/chattr +C "${storage}"
        ${pkgs.util-linux}/bin/fallocate -l "${storage}" "${state}"
      fi
      ${tinyQemu}/bin/qemu-kvm -enable-kvm -drive file="${rootfs}",if=virtio,format=raw,media=disk,readonly=on -drive file="${state}",if=virtio,format=raw,media=disk -nic tap,id=net0,ifname="vm-$name",model=virtio,script=no,downscript=no -nographic -vga none -serial stdio -cpu host -m "${memory}" -smp "${toString threads}" -kernel "${linux}" -initrd "${initrd}" -append "${cmdline}"
    '');
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

    systemd.services = lib.mapAttrs' mkService cfg.vms;

  };

}
